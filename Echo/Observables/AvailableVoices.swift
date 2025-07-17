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
        EchoLogger.debug("AvailableVoices.init() called", category: .voice)
        // Don't automatically fetch voices on init to avoid Assistant Framework calls
        // Voices will be fetched when actually needed
        EchoLogger.debug("AvailableVoices.init() completed", category: .voice)
    }
    
    func ensureInitialized() {
        guard !hasInitialized else { return }
        EchoLogger.debug("AvailableVoices.ensureInitialized() - first time initialization", category: .voice)
        hasInitialized = true

        // Load basic voices on background thread, then request personal voice authorization
        EchoLogger.debug("Loading basic voices on background thread", category: .voice)
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchVoices()

            // Then request personal voice authorization for additional voices
            DispatchQueue.main.async {
                self.requestPersonalVoiceAuthorization()
            }
        }
    }

    private func requestPersonalVoiceAuthorization() {
        EchoLogger.debug("AvailableVoices.requestPersonalVoiceAuthorization() called", category: .voice)
        if #available(iOS 17.0, *) {
            EchoLogger.debug("About to call AVSpeechSynthesizer.requestPersonalVoiceAuthorization", category: .voice)
            AVSpeechSynthesizer.requestPersonalVoiceAuthorization { status in
                DispatchQueue.main.async {
                    EchoLogger.debug("Personal voice authorization completed with status: \(status)", category: .voice)
                    switch status {
                    case .authorized:
                        self.personalVoiceAuthorized = true
                        EchoLogger.debug("Personal voice authorized, refetching voices", category: .voice)
                        // Call fetchVoices on background thread to avoid blocking main thread
                        DispatchQueue.global(qos: .userInitiated).async {
                            self.fetchVoices()
                        }
                    case .denied, .notDetermined, .unsupported:
                        self.personalVoiceAuthorized = false
                        EchoLogger.debug("Personal voice not authorized", category: .voice)
                        // Don't refetch - we already have basic voices loaded
                    @unknown default:
                        self.personalVoiceAuthorized = false
                        EchoLogger.debug("Personal voice unknown status", category: .voice)
                        // Don't refetch - we already have basic voices loaded
                    }
                }
            }
        } else {
            EchoLogger.debug("iOS < 17.0, no personal voice support", category: .voice)
            // Don't call fetchVoices() again - we already loaded basic voices
        }
    }
    
    func fetchVoices() {
        // EchoLogger.debug("AvailableVoices.fetchVoices() called - about to call speechVoices()", category: .voice)
        let aVFvoices = AVSpeechSynthesisVoice.speechVoices()
        // EchoLogger.debug("AvailableVoices.fetchVoices() - speechVoices() completed, found \(aVFvoices.count) voices", category: .voice)

        var tempVoicesByLang: [String: [AVSpeechSynthesisVoice]] = [:]

        for voice in aVFvoices {
            if voice.voiceTraits == .isPersonalVoice {
                continue
            }

            var currentList = tempVoicesByLang[voice.language] ?? []
            currentList.append(voice)
            tempVoicesByLang[voice.language] = currentList
        }

        if #available(iOS 17.0, *), personalVoiceAuthorized {
            let personalVoices = aVFvoices.filter { $0.voiceTraits.contains(.isPersonalVoice) }
            for personalVoice in personalVoices {
                let language = "pv" // Personal Voice
                var currentList = tempVoicesByLang[language] ?? []
                currentList.append(personalVoice)
                tempVoicesByLang[language] = currentList
            }
        }

        // Update @Published properties on main thread
        DispatchQueue.main.async {
            self.voicesByLang = tempVoicesByLang
            self.voices = aVFvoices
            // EchoLogger.debug("AvailableVoices.fetchVoices() - updated UI on main thread, voicesByLang has \(tempVoicesByLang.count) languages", category: .voice)
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
