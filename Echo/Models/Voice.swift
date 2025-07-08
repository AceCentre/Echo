//
//  Voice.swift
// Echo
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
        print("DEBUG: setToDefaultCueVoice() called")
        // Get all available voices and find a suitable one
        let allVoices = AVSpeechSynthesisVoice.speechVoices()

        // Try to find voices for the current locale first
        let currentLocale = Locale.current.identifier
        let localeVoices = allVoices.filter { $0.language == currentLocale }

        // If no voices for current locale, try language code only (e.g., "en" from "en-GB")
        let languageCode = String(currentLocale.prefix(2))
        let languageVoices = localeVoices.isEmpty ? allVoices.filter { $0.language.hasPrefix(languageCode) } : localeVoices

        // If still no voices, use all available voices
        let availableVoices = languageVoices.isEmpty ? allVoices : languageVoices

        // Get the first voice as default
        guard let firstVoice = availableVoices.first else {
            // If no voices available at all, use Alex as fallback
            if let alexVoice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex) {
                self.voiceId = alexVoice.identifier
                self.voiceName = alexVoice.name
            } else {
                // Last resort fallback
                self.voiceId = "com.apple.ttsbundle.Samantha-compact"
                self.voiceName = "Samantha"
            }
            return
        }

        // Try to find a voice with different gender than the first one
        let firstGender = firstVoice.gender
        let targetGender: AVSpeechSynthesisVoiceGender = firstGender == .male ? .female : .male
        let targetVoice = availableVoices.first(where: { $0.gender == targetGender })

        let selectedVoice = targetVoice ?? firstVoice
        self.voiceId = selectedVoice.identifier
        self.voiceName = selectedVoice.name
    }
    
    func setToDefaultSpeakingVoice() {
        print("DEBUG: setToDefaultSpeakingVoice() called")
        // Get all available voices and find a suitable one
        let allVoices = AVSpeechSynthesisVoice.speechVoices()

        // Try to find voices for the current locale first
        let currentLocale = Locale.current.identifier
        let localeVoices = allVoices.filter { $0.language == currentLocale }

        // If no voices for current locale, try language code only (e.g., "en" from "en-GB")
        let languageCode = String(currentLocale.prefix(2))
        let languageVoices = localeVoices.isEmpty ? allVoices.filter { $0.language.hasPrefix(languageCode) } : localeVoices

        // If still no voices, use all available voices
        let availableVoices = languageVoices.isEmpty ? allVoices : languageVoices

        // Use the first available voice, or Alex as fallback
        if let firstVoice = availableVoices.first {
            self.voiceId = firstVoice.identifier
            self.voiceName = firstVoice.name
        } else {
            // If no voices available at all, use Alex as fallback
            if let alexVoice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex) {
                self.voiceId = alexVoice.identifier
                self.voiceName = alexVoice.name
            } else {
                // Last resort fallback
                self.voiceId = "com.apple.ttsbundle.Samantha-compact"
                self.voiceName = "Samantha"
            }
        }
    }
}
