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
            print("This error message from SpeechSynthesizer \(error.localizedDescription)")
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
        print("🔊 DEBUG: VoiceController.play() called with text: '\(text ?? "nil")' and voiceId: \(voiceOptions.voiceId)")
        print("🔊 DEBUG: VoiceController.play() call stack:")
        Thread.callStackSymbols.forEach { print("  \($0)") }

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

            // Use existing cue voice or create a safe default without calling setToDefaultCueVoice
            let cueVoice: Voice
            if let existingCueVoice = unwrappedSettings.cueVoice {
                cueVoice = existingCueVoice
            } else {
                // Create a safe default voice without triggering Assistant Framework
                cueVoice = Voice(rate: 35, volume: 100, voiceId: "com.apple.ttsbundle.Samantha-compact", voiceName: "Samantha")
            }

            play(text, voiceOptions: cueVoice, pan: direction.pan, isFast: true, cb: cb)
        }
    }
    
    
    
    func playCue(_ text: String?, isFast: Bool = false, cb: (() -> Void)? = {}) {
        if let unwrappedSettings = settings {
            let direction: AudioDirection = unwrappedSettings.splitAudio ? unwrappedSettings.cueDirection : .center

            // Use existing cue voice or create a safe default without calling setToDefaultCueVoice
            let cueVoice: Voice
            if let existingCueVoice = unwrappedSettings.cueVoice {
                cueVoice = existingCueVoice
            } else {
                // Create a safe default voice without triggering Assistant Framework
                cueVoice = Voice(rate: 35, volume: 100, voiceId: "com.apple.ttsbundle.Samantha-compact", voiceName: "Samantha")
            }

            play(text, voiceOptions: cueVoice, pan: direction.pan, isFast: isFast, cb: cb)
        }
    }
    
    func playSpeaking(_ text: String, cb: (() -> Void)? = {}) {
        if let unwrappedSettings = settings {

            let direction: AudioDirection = unwrappedSettings.splitAudio ? unwrappedSettings.speakDirection : .center

            // Use existing speaking voice or create a safe default without calling setToDefaultSpeakingVoice
            let speakingVoice: Voice
            if let existingSpeakingVoice = unwrappedSettings.speakingVoice {
                speakingVoice = existingSpeakingVoice
            } else {
                // Create a safe default voice without triggering Assistant Framework
                speakingVoice = Voice(rate: 35, volume: 100, voiceId: "com.apple.ttsbundle.Samantha-compact", voiceName: "Samantha")
            }

            play(text, voiceOptions: speakingVoice, pan: direction.pan, cb: cb)
        }
    }
}
