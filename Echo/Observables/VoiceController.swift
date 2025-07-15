//
//  VoiceEngine.swift
// Echo
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation
import AVKit
import SwiftUI
import ObjectiveC

// Helper class to handle speech synthesis completion for voice previews
class SafeSynthesizerDelegate: NSObject, AVSpeechSynthesizerDelegate {
    private let callback: (() -> Void)?

    init(callback: (() -> Void)?) {
        self.callback = callback
        super.init()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("🔊 SafeSynthesizerDelegate: Speech synthesis completed")
        DispatchQueue.main.async {
            self.callback?()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("🔊 SafeSynthesizerDelegate: Speech synthesis cancelled")
        DispatchQueue.main.async {
            self.callback?()
        }
    }
}

class VoiceController: ObservableObject {
    @Published var phase: ScenePhase = .active
    
    var customAV: AudioEngine?
    
    var settings: Settings?

    init() {
        phase = .active
        // This makes it work in silent mode by setting the audio to playback
        configureAudioSession()
    }

    private func configureAudioSession() {
        print("🔊 VoiceController: Configuring audio session")
        do {
            // Use playback category with options to mix with other audio
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .spokenAudio,
                options: [.duckOthers, .mixWithOthers]
            )

            // Set preferred sample rate and buffer duration
            try AVAudioSession.sharedInstance().setPreferredSampleRate(44100.0)
            try AVAudioSession.sharedInstance().setPreferredIOBufferDuration(0.005)

            // Activate the session
            try AVAudioSession.sharedInstance().setActive(true)
            print("🔊 VoiceController: Audio session configured successfully")
        } catch let error {
            print("🔊 VoiceController: Audio session setup error - \(error.localizedDescription)")
            // Don't crash on audio session errors, just log them
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

        // Test basic speech synthesis capability
        testBasicSpeech()
    }

    private func testBasicSpeech() {
        print("🔊 VoiceController: Testing basic speech synthesis")

        // Log available voices for debugging iOS 26 Beta issues
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        print("🔊 VoiceController: Available voices on this device:")
        for (index, voice) in allVoices.prefix(10).enumerated() {
            print("🔊   \(index + 1). \(voice.name) (\(voice.identifier)) - \(voice.language)")
        }
        if allVoices.count > 10 {
            print("🔊   ... and \(allVoices.count - 10) more voices")
        }

        // Create a very simple test
        let testSynthesizer = AVSpeechSynthesizer()
        let testUtterance = AVSpeechUtterance(string: "Test")
        testUtterance.rate = 0.5
        testUtterance.volume = 0.1 // Very quiet

        // Try with system default voice
        if let systemVoice = AVSpeechSynthesisVoice(language: "en-US") {
            testUtterance.voice = systemVoice
            print("🔊 VoiceController: Using en-US voice for test: \(systemVoice.name)")
        } else {
            print("🔊 VoiceController: No en-US voice found, using system default")
        }

        print("🔊 VoiceController: Attempting test speech")
        testSynthesizer.speak(testUtterance)
    }
    
    func play(_ text: String?, voiceOptions: Voice, pan: Float, isFast: Bool = false, cb: (() -> Void)? = {}) {
        // Safety check: Don't attempt speech if app is not active
        guard phase == .active else {
            print("🔊 VoiceController: Skipping speech - app not active (phase: \(phase))")
            cb?()
            return
        }

        // Safety check: Validate voice options
        guard voiceOptions.voiceId != "unknown" && !voiceOptions.voiceId.isEmpty else {
            print("🔊 VoiceController: Invalid voice ID, skipping speech")
            cb?()
            return
        }

        // Reduced logging - only log significant events, not every play call
        if let text = text, text.count > 10 {
            print("🔊 VoiceController.play() - long text: '\(String(text.prefix(20)))...'")
        }

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

            // Use existing cue voice or create a safe default
            let cueVoice: Voice
            if let existingCueVoice = unwrappedSettings.cueVoice {
                cueVoice = existingCueVoice
            } else {
                // Create a safe default voice using system default
                cueVoice = createSafeDefaultVoice()
            }

            play(text, voiceOptions: cueVoice, pan: direction.pan, isFast: true, cb: cb)
        }
    }
    
    
    
    func playCue(_ text: String?, isFast: Bool = false, cb: (() -> Void)? = {}) {
        if let unwrappedSettings = settings {
            let direction: AudioDirection = unwrappedSettings.splitAudio ? unwrappedSettings.cueDirection : .center

            // Use existing cue voice or create a safe default
            let cueVoice: Voice
            if let existingCueVoice = unwrappedSettings.cueVoice {
                cueVoice = existingCueVoice
            } else {
                // Create a safe default voice using system default
                cueVoice = createSafeDefaultVoice()
            }

            // Use direct synthesis for voice previews to prevent crashes
            if text?.contains("this is your cue voice") == true {
                useSafeDirectSynthesis(text: text ?? "", voiceOptions: cueVoice, cb: cb)
            } else {
                play(text, voiceOptions: cueVoice, pan: direction.pan, isFast: isFast, cb: cb)
            }
        }
    }

    func playSpeaking(_ text: String, cb: (() -> Void)? = {}) {
        if let unwrappedSettings = settings {

            let direction: AudioDirection = unwrappedSettings.splitAudio ? unwrappedSettings.speakDirection : .center

            // Use existing speaking voice or create a safe default
            let speakingVoice: Voice
            if let existingSpeakingVoice = unwrappedSettings.speakingVoice {
                speakingVoice = existingSpeakingVoice
            } else {
                // Create a safe default voice using system default
                speakingVoice = createSafeDefaultVoice()
            }

            // Use direct synthesis for voice previews to prevent crashes
            if text.contains("this is your speaking voice") {
                useSafeDirectSynthesis(text: text, voiceOptions: speakingVoice, cb: cb)
            } else {
                play(text, voiceOptions: speakingVoice, pan: direction.pan, cb: cb)
            }
        }
    }

    // MARK: - Safe Direct Synthesis

    /// Uses direct AVSpeechSynthesizer for voice previews to prevent crashes
    private func useSafeDirectSynthesis(text: String, voiceOptions: Voice, cb: (() -> Void)? = {}) {
        print("🔊 VoiceController: Using safe direct synthesis for preview: \(text)")
        print("🔊 VoiceController: Requested voice ID: \(voiceOptions.voiceId)")

        // Create a new synthesizer for direct speech
        let safeSynthesizer = AVSpeechSynthesizer()

        // Create a delegate to handle completion
        let delegate = SafeSynthesizerDelegate(callback: cb)
        safeSynthesizer.delegate = delegate

        // Create a simple utterance without SSML
        let utterance = AVSpeechUtterance(string: text)

        // Set basic properties with safe ranges
        let safeRate = max(0.1, min(1.0, Float(voiceOptions.rate / 100)))
        let safeVolume = max(0.0, min(1.0, Float(voiceOptions.volume / 100)))

        utterance.rate = safeRate
        utterance.volume = safeVolume
        utterance.pitchMultiplier = 1.0

        // Try to find the actual requested voice first
        var selectedVoice: AVSpeechSynthesisVoice?

        // First, try to find the voice by identifier in available voices
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        selectedVoice = availableVoices.first { $0.identifier == voiceOptions.voiceId }

        if selectedVoice == nil {
            print("🔊 VoiceController: Voice ID \(voiceOptions.voiceId) not found in available voices")
            // Try to create by identifier (this might work on iOS 26 Beta)
            selectedVoice = AVSpeechSynthesisVoice(identifier: voiceOptions.voiceId)
        }

        if selectedVoice == nil {
            print("🔊 VoiceController: Failed to create voice, trying en-US system voice")
            selectedVoice = AVSpeechSynthesisVoice(language: "en-US")
        }

        if selectedVoice == nil {
            print("🔊 VoiceController: Using default system voice as last resort")
            selectedVoice = AVSpeechSynthesisVoice()
        }

        utterance.voice = selectedVoice
        print("🔊 VoiceController: Using voice: \(selectedVoice?.name ?? "Unknown") (\(selectedVoice?.identifier ?? "Unknown"))")

        // Store delegate to prevent deallocation
        objc_setAssociatedObject(safeSynthesizer, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // Speak directly
        print("🔊 VoiceController: Starting safe direct synthesis")
        safeSynthesizer.speak(utterance)
    }

    // MARK: - Helper Methods

    /// Creates a safe default voice that works on all iOS versions including iOS 26 Beta
    private func createSafeDefaultVoice() -> Voice {
        print("🔊 VoiceController: Creating safe default voice")

        // Get all available voices
        let allVoices = AVSpeechSynthesisVoice.speechVoices()
        print("🔊 VoiceController: Found \(allVoices.count) available voices")

        // Try to find an English voice first
        let englishVoices = allVoices.filter { $0.language.hasPrefix("en") }

        if let firstEnglishVoice = englishVoices.first {
            print("🔊 VoiceController: Using English voice: \(firstEnglishVoice.name) (\(firstEnglishVoice.identifier))")
            return Voice(rate: 35, volume: 100, voiceId: firstEnglishVoice.identifier, voiceName: firstEnglishVoice.name)
        } else if let firstVoice = allVoices.first {
            print("🔊 VoiceController: Using first available voice: \(firstVoice.name) (\(firstVoice.identifier))")
            return Voice(rate: 35, volume: 100, voiceId: firstVoice.identifier, voiceName: firstVoice.name)
        } else {
            print("🔊 VoiceController: No voices available, using system default")
            // Last resort - use system default
            let systemVoice = AVSpeechSynthesisVoice()
            return Voice(rate: 35, volume: 100, voiceId: systemVoice.identifier, voiceName: systemVoice.name)
        }
    }
}
