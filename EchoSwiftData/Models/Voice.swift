//
//  Voice.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation
import SwiftData
import AVKit

@Model
class Voice {
    var rate: Double
    var volume: Double
    var voiceId: String
    var voiceName: String
    
    init(rate: Double, volume: Double, voiceId: String, voiceName: String) {
        self.rate = rate
        self.volume = volume
        self.voiceId = voiceId
        self.voiceName = voiceName
    }
    
    init() {
        self.rate = 50
        self.volume = 100
        self.voiceId = "unknown"
        self.voiceName = "unknown"
    }
    
    func setToDefaultCueVoice() {
        let langCode = AVSpeechSynthesisVoice.currentLanguageCode()
        if let defaultVoice = AVSpeechSynthesisVoice(language: langCode) {
            let voiceId = defaultVoice.identifier
            let defaultVoiceFull = AVSpeechSynthesisVoice(identifier: voiceId) ?? AVSpeechSynthesisVoice()
            let defaultGender = defaultVoiceFull.gender
            let targetGender: AVSpeechSynthesisVoiceGender = defaultGender == .male ? .female : .male
            
            let voices = AVSpeechSynthesisVoice
                .speechVoices()
                .filter({
                    $0.language == langCode
                })
            
            let targetVoice = voices.first(where: { $0.gender == targetGender })
            let voice = targetVoice ?? voices[0]
            
            self.voiceId = voice.identifier
            self.voiceName = voice.name
        }
    }
    
    func setToDefaultSpeakingVoice() {
        let langCode = AVSpeechSynthesisVoice.currentLanguageCode()
        let defaultVoice = AVSpeechSynthesisVoice(language: langCode) ?? AVSpeechSynthesisVoice()
        
        self.voiceId = defaultVoice.identifier
        self.voiceName = defaultVoice.name
    }
}
