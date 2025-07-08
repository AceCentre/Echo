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
    
    private var hasInitialized = false

    init() {
        print("🔊 DEBUG: AvailableVoices.init() called")
        // Don't automatically fetch voices on init to avoid Assistant Framework calls
        // Voices will be fetched when actually needed
        print("🔊 DEBUG: AvailableVoices.init() completed")
    }
    
    func ensureInitialized() {
        guard !hasInitialized else { return }
        print("🔊 DEBUG: AvailableVoices.ensureInitialized() - first time initialization")
        hasInitialized = true

        // Load basic voices immediately, then request personal voice authorization
        print("🔊 DEBUG: Loading basic voices immediately")
        fetchVoices()

        // Then request personal voice authorization for additional voices
        requestPersonalVoiceAuthorization()
    }

    private func requestPersonalVoiceAuthorization() {
        print("🔊 DEBUG: AvailableVoices.requestPersonalVoiceAuthorization() called")
        if #available(iOS 17.0, *) {
            print("🔊 DEBUG: About to call AVSpeechSynthesizer.requestPersonalVoiceAuthorization")
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
                DispatchQueue.main.async {
                    print("🔊 DEBUG: Personal voice authorization completed with status: \(status)")
                    switch status {
                    case .authorized:
                        self.personalVoiceAuthorized = true
                        print("🔊 DEBUG: Personal voice authorized, refetching voices")
                        self.fetchVoices()  // Refetch to include personal voices
                    case .denied, .notDetermined, .unsupported:
                        self.personalVoiceAuthorized = false
                        print("🔊 DEBUG: Personal voice not authorized")
                        // Don't refetch - we already have basic voices loaded
                    @unknown default:
                        self.personalVoiceAuthorized = false
                        print("🔊 DEBUG: Personal voice unknown status")
                        // Don't refetch - we already have basic voices loaded
                    }
                }
            }
        } else {
            print("🔊 DEBUG: iOS < 17.0, no personal voice support")
            // Don't call fetchVoices() again - we already loaded basic voices
        }
    }
    
    func fetchVoices() {
        print("🔊 DEBUG: AvailableVoices.fetchVoices() called - about to call speechVoices()")
        let aVFvoices = AVSpeechSynthesisVoice.speechVoices()
        print("🔊 DEBUG: AvailableVoices.fetchVoices() - speechVoices() completed, found \(aVFvoices.count) voices")
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
        print("🔊 DEBUG: AvailableVoices.fetchVoices() - processed voices, voicesByLang has \(voicesByLang.count) languages")

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
        ensureInitialized()
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
        ensureInitialized()
        return self.voicesByLang[lang] ?? []
    }
}
