//
//  AvailableVoices.swift
// Echo
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation
import AVKit

class AvailableVoices: ObservableObject {
    @Published var voices: [AVSpeechSynthesisVoice] = []
    @Published var voicesByLang: [String: [AVSpeechSynthesisVoice]] = [:]
    @Published var personalVoiceAuthorized: Bool = false
    
    init() {
        requestPersonalVoiceAuthorization()
    }
    
    func requestPersonalVoiceAuthorization() {
        if #available(iOS 17.0, *) {
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        self.personalVoiceAuthorized = true
                        self.fetchVoices()  // Fetch all voices including personal voices
                    case .denied, .notDetermined, .unsupported:
                        self.personalVoiceAuthorized = false
                        self.fetchVoices()  // Fetch only non-personal voices
                    @unknown default:
                        self.personalVoiceAuthorized = false
                        self.fetchVoices()
                    }
                }
            }
        } else {
            fetchVoices() // iOS < 17.0, no personal voice support
        }
    }
    
    func fetchVoices() {
        let aVFvoices = AVSpeechSynthesisVoice.speechVoices()
        voicesByLang = [:]
        
        for voice in aVFvoices {
            if voice.voiceTraits == .isPersonalVoice {
                continue
            }
            
            var currentList = voicesByLang[voice.language] ?? []
            currentList.append(voice)
            voicesByLang[voice.language] = currentList
        }
        
        voices = aVFvoices
        
        if #available(iOS 17.0, *), personalVoiceAuthorized {
            let personalVoices = aVFvoices.filter { $0.voiceTraits.contains(.isPersonalVoice) }
            for personalVoice in personalVoices {
                let language = "pv" // Personal Voice
                var currentList = voicesByLang[language] ?? []
                currentList.append(personalVoice)
                voicesByLang[language] = currentList
            }
        }
    }
    
    /***
        Sorts all the languages available by the following criteria
     
        * Push personal voices to the top
        * Push users language and region to the top
        * Push users language to the top
        * Sort alphabetically (by display name)
     */
    func sortedKeys() -> [String] {
        let currentLocale: String = Locale.current.language.languageCode?.identifier ?? "en"
        let currentIdentifier: String = Locale.current.identifier(.bcp47)
        
        return Array(voicesByLang.keys).sorted(by: {
            let zeroLocale = Locale(identifier: $0).language.languageCode?.identifier ?? "en"
            let oneLocale = Locale(identifier: $1).language.languageCode?.identifier ?? "en"
            let zeroFullLanguage = getLanguageAndRegion($0)
            let oneFullLanguage = getLanguageAndRegion($1)
            
            if($0 == "pv") {
                return true
            }
            
            if($1 == "pv") {
                return false
            }
            
            if $0 == currentIdentifier {
                return true
            }
            
            if $1 == currentIdentifier {
                return false
            }
            
            if zeroLocale == currentLocale && oneLocale == currentLocale {
                return zeroFullLanguage < oneFullLanguage
            }
            
            if zeroLocale == currentLocale {
                return true
            }
            
            if oneLocale == currentLocale {
                return false
            }
            
            return zeroFullLanguage < oneFullLanguage
        })
    }
    
    func voicesForLang(_ lang: String) -> [AVSpeechSynthesisVoice] {
        return self.voicesByLang[lang] ?? []
    }
}
