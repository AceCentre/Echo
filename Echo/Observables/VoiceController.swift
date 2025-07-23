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
        // This makes it work in silent mode by setting the audio to playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch let error {
            EchoLogger.error("Audio session configuration failed: \(error.localizedDescription)", category: .voice)
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

            play(text, voiceOptions: cueVoice, pan: direction.pan, isFast: true, cb: cb)
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
