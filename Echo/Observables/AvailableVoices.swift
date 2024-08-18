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
    @Published var voicesByLang: [String: [AVSpeechSynthesisVoice]]
    @Published var personalVoiceAuthorized: Bool = false
    
    init() {
        voices = AVSpeechSynthesisVoice.speechVoices()
        voicesByLang = [:]
        for voice in voices {
            var currentList = voicesByLang[voice.language] ?? []
            currentList.append(voice)
            voicesByLang[voice.language] = currentList
        }
    }
    
    func requestPersonalVoiceAuthorization() {
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized:
                        self.personalVoiceAuthorized = true
                    case .denied, .notDetermined, .unsupported:
                        self.personalVoiceAuthorized = false
                    @unknown default:
                        self.personalVoiceAuthorized = false
                    }
                    // You might want to fetch voices again if the status changes
                    if self.personalVoiceAuthorized {
                        self.fetchPersonalVoices()
                    }
                }
            }
        }
    
    private func fetchPersonalVoices() {
           // Add Personal Voice if authorized
           if let personalVoice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.PersonalVoice") {
               voices.append(personalVoice)
               let language = personalVoice.language
               var currentList = voicesByLang[language] ?? []
               currentList.append(personalVoice)
               voicesByLang[language] = currentList
           }
       }
    
    /***
        Sorts all the languages availble by the following criteria
     
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
