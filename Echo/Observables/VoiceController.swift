//
//  VoiceEngine.swift
// Echo
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation
import AVKit
import SwiftUI

class VoiceController: ObservableObject {
    @Published var phase: ScenePhase = .active
    
    var customAV: AudioEngine?
    
    var settings: Settings?

    init() {
        phase = .active
        // Configure audio session to work with ARKit and speech synthesis
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()

            // Use playAndRecord category to be compatible with ARKit (which may use microphone)
            // This prevents audio session conflicts between ARKit and speech synthesis
            try audioSession.setCategory(.playAndRecord,
                                       mode: .default,
                                       options: [.defaultToSpeaker, .allowBluetooth])

            // Activate the session
            try audioSession.setActive(true)

            EchoLogger.debug("Audio session configured successfully for ARKit compatibility", category: .voice)
        } catch let error {
            EchoLogger.error("Audio session configuration failed: \(error.localizedDescription)", category: .voice)

            // Fallback to simpler configuration
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                EchoLogger.debug("Fallback audio session configuration applied", category: .voice)
            } catch let fallbackError {
                EchoLogger.error("Fallback audio session configuration also failed: \(fallbackError.localizedDescription)", category: .voice)
            }
        }
    }
    
    func setPhase(_ newPhase: ScenePhase) {
        phase = newPhase
        
        if phase == .inactive || phase == .background {
            self.stop()
        }
    }
    
    func loadSettings(_ settings: Settings) {
        self.settings = settings
    }
    
    func play(_ text: String?, voiceOptions: Voice, pan: Float, isFast: Bool = false, cb: (() -> Void)? = {}) {
        // Only log errors or significant issues

        let unwrappedAv = self.customAV ?? AudioEngine()
        self.customAV = unwrappedAv

        unwrappedAv.stop()
        unwrappedAv.speak(text: text ?? "", voiceOptions: voiceOptions, pan: pan, scenePhase: phase, isFast: isFast, cb: cb)
    }
    
    func stop() {
        customAV?.stop()
    }

    /// Reset audio session when conflicts are detected (e.g., with ARKit)
    func resetAudioSession() {
        EchoLogger.debug("Resetting audio session due to conflicts", category: .voice)

        do {
            // Deactivate current session
            try AVAudioSession.sharedInstance().setActive(false)

            // Small delay to allow system cleanup
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.configureAudioSession()
            }
        } catch {
            EchoLogger.error("Failed to reset audio session: \(error.localizedDescription)", category: .voice)
            // Try to reconfigure anyway
            configureAudioSession()
        }
    }
    
    func playFastCue(_ text: String, cb: (() -> Void)? = {}) {
        if let unwrappedSettings = settings {
            let direction: AudioDirection = unwrappedSettings.splitAudio ? unwrappedSettings.cueDirection : .center

            // Use existing cue voice or create a safe default using available voices
            let cueVoice: Voice
            if let existingCueVoice = unwrappedSettings.cueVoice {
                cueVoice = existingCueVoice
            } else {
                // Create a safe default voice using first available voice
                cueVoice = createSafeDefaultVoice()
            }

            // Use direct synthesis for fast cue to avoid buffer issues with rapid audio generation
            // This bypasses the file-based synthesis that's causing AVAudioBuffer errors
            playDirect(text, voiceOptions: cueVoice, pan: direction.pan, cb: cb)
        }
    }
    
    
    
    func playCue(_ text: String?, isFast: Bool = false, cb: (() -> Void)? = {}) {
        if let unwrappedSettings = settings {
            let direction: AudioDirection = unwrappedSettings.splitAudio ? unwrappedSettings.cueDirection : .center

            // Use existing cue voice or create a safe default using available voices
            let cueVoice: Voice
            if let existingCueVoice = unwrappedSettings.cueVoice {
                cueVoice = existingCueVoice
            } else {
                // Create a safe default voice using first available voice
                cueVoice = createSafeDefaultVoice()
            }

            play(text, voiceOptions: cueVoice, pan: direction.pan, isFast: isFast, cb: cb)
        }
    }
    
    func playSpeaking(_ text: String, cb: (() -> Void)? = {}) {
        if let unwrappedSettings = settings {

            let direction: AudioDirection = unwrappedSettings.splitAudio ? unwrappedSettings.speakDirection : .center

            // Use existing speaking voice or create a safe default using available voices
            let speakingVoice: Voice
            if let existingSpeakingVoice = unwrappedSettings.speakingVoice {
                speakingVoice = existingSpeakingVoice
            } else {
                // Create a safe default voice using first available voice
                speakingVoice = createSafeDefaultVoice()
            }

            // Use direct synthesis for speaking voice for reliable audio output
            playDirect(text, voiceOptions: speakingVoice, pan: direction.pan, cb: cb)
        }
    }

    func playDirect(_ text: String?, voiceOptions: Voice, pan: Float, cb: (() -> Void)? = {}) {
        let unwrappedAv = self.customAV ?? AudioEngine()
        self.customAV = unwrappedAv

        unwrappedAv.stop()
        unwrappedAv.speakDirect(text: text ?? "", voiceOptions: voiceOptions, pan: pan, scenePhase: phase, cb: cb)
    }

    private func createSafeDefaultVoice() -> Voice {
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()

        // Try to get a voice for current locale first
        let currentLocale = Locale.current.identifier
        let localeVoices = availableVoices.filter { $0.language == currentLocale }

        // If no voices for current locale, try language code only
        let languageCode = String(currentLocale.prefix(2))
        let languageVoices = localeVoices.isEmpty ? availableVoices.filter { $0.language.hasPrefix(languageCode) } : localeVoices

        // Use the best available voice
        let usableVoices = languageVoices.isEmpty ? availableVoices : languageVoices

        if let firstVoice = usableVoices.first {
            return Voice(rate: 35, volume: 100, voiceId: firstVoice.identifier, voiceName: firstVoice.name)
        } else {
            // Ultimate fallback - empty voiceId will let the system choose
            return Voice(rate: 35, volume: 100, voiceId: "", voiceName: "System Default")
        }
    }
}
