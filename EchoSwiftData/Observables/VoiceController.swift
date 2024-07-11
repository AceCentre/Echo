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
            
            let defaultCueVoice = Voice()
            defaultCueVoice.setToDefaultCueVoice()
            
            let cueVoice = unwrappedSettings.cueVoice ?? defaultCueVoice
            
            play(text, voiceOptions: cueVoice, pan: direction.pan, isFast: true, cb: cb)
        }
    }
    
    
    
    func playCue(_ text: String?, cb: (() -> Void)? = {}) {
        if let unwrappedSettings = settings {
            let direction: AudioDirection = unwrappedSettings.splitAudio ? unwrappedSettings.cueDirection : .center
            
            let defaultCueVoice = Voice()
            defaultCueVoice.setToDefaultCueVoice()
                        
            let cueVoice = unwrappedSettings.cueVoice ?? defaultCueVoice
            
            play(text, voiceOptions: cueVoice, pan: direction.pan, cb: cb)
        }
    }
    
    func playSpeaking(_ text: String, cb: (() -> Void)? = {}) {
        if let unwrappedSettings = settings {
            
            let direction: AudioDirection = unwrappedSettings.splitAudio ? unwrappedSettings.speakDirection : .center
            
            let defaultSpeakingVoice = Voice()
            defaultSpeakingVoice.setToDefaultSpeakingVoice()
            
            let speakingVoice = unwrappedSettings.speakingVoice ?? defaultSpeakingVoice
            
            play(text, voiceOptions: speakingVoice, pan: direction.pan, cb: cb)
        }
    }
}
