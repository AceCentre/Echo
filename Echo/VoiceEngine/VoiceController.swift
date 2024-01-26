//
//  VoiceEngine.swift
//  Echo
//
//  Created by Gavin Henderson on 03/10/2023.
//

import Foundation
import AVKit
import SharedEcho

class VoiceController: ObservableObject, Analytic {
    @Published var speakingVoiceOptions: VoiceOptions = VoiceOptions()
    @Published var cueVoiceOptions: VoiceOptions = VoiceOptions()
    
    var analytics: Analytics?
    var customAV: AudioEngine?
    
    func getAnalyticData() -> [String: Any] {
        return [
            "cueVoiceVoiceId": cueVoiceOptions.voiceId,
            "cueVoiceRate": cueVoiceOptions.rate,
            "cueVoicePitch": cueVoiceOptions.pitch,
            "cueVoiceVolume": cueVoiceOptions.volume,
            "speakingVoiceVoiceId": speakingVoiceOptions.voiceId,
            "speakingVoiceRate": speakingVoiceOptions.rate,
            "speakingVoicePitch": speakingVoiceOptions.pitch,
            "speakingVoiceVolume": speakingVoiceOptions.volume
        ]
    }
    
   init() {
        // This makes it work in silent mode by setting the audio to playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch let error {
            print("This error message from SpeechSynthesizer \(error.localizedDescription)")
        }
    }
    
    func play(_ text: String, voiceOptions: VoiceOptions, cb: (() -> Void)? = {}) {      
            let textWithSpaces = text.replacingOccurrences(of: "·", with: " ")
            let unwrappedAv = self.customAV ?? AudioEngine()
            self.customAV = unwrappedAv
            
            unwrappedAv.stop()
            unwrappedAv.speak(text: textWithSpaces, voiceOptions: voiceOptions, cb: cb)        
    }
    
    func stop() {
        customAV?.stop()
    }
    
    func playFastCue(_ text: String, cb: (() -> Void)? = {}) {
        play(text, voiceOptions: VoiceOptions(
            voiceId: cueVoiceOptions.voiceId,
            rate: 75,
            pitch: cueVoiceOptions.pitch,
            volume: cueVoiceOptions.volume
        ), cb: cb)
    }
    
    func playCue(_ text: String, cb: (() -> Void)? = {}) {
        analytics?.event(.readCue)
        play(text, voiceOptions: cueVoiceOptions, cb: cb)
    }
    
    func playSpeaking(_ text: String, cb: (() -> Void)? = {}) {
        let numberOfWords = getNumberOfWords(text)
        let averageWordLength = getAverageWordLength(text)
        let totalUtteranceLength = getTotalUtteranceLength(text)
        
        analytics?.utteranceSpoken(
            numberOfWords: numberOfWords,
            averageWordLength: averageWordLength,
            totalUtteranceLength: totalUtteranceLength
        )
        play(text, voiceOptions: speakingVoiceOptions, cb: cb)
    }
    
    func load(analytics: Analytics? = nil) {
        if analytics != nil {
            self.analytics = analytics
        }
        
        if let speakingVoiceData = UserDefaults.standard.data(forKey: StorageKeys.speakingVoiceOptions) {
            do {
                let decoder = JSONDecoder()
                speakingVoiceOptions = try decoder.decode(VoiceOptions.self, from: speakingVoiceData)

            } catch {
                self.setSpeakingVoiceToDefault()
            }
        } else {
            self.setSpeakingVoiceToDefault()
            self.saveSpeakingOptions()
        }
        
        if let cueVoiceData = UserDefaults.standard.data(forKey: StorageKeys.cueVoiceOptions) {
            do {
                let decoder = JSONDecoder()
                cueVoiceOptions = try decoder.decode(VoiceOptions.self, from: cueVoiceData)
            } catch {
                self.setCueVoiceToDefault()
            }
        } else {
            self.setCueVoiceToDefault()
            self.saveCueOptions()
        }
    }
    
    /***
     Set the speaking voice to the system default voice
    */
    func setSpeakingVoiceToDefault() {
        let langCode = AVSpeechSynthesisVoice.currentLanguageCode()
        let defaultVoice = AVSpeechSynthesisVoice(language: langCode) ?? AVSpeechSynthesisVoice()
        
        self.speakingVoiceOptions = VoiceOptions(defaultVoice.identifier)
    }

    /***
        Set the cue voice to the first voice that is the same language to default voice but opposite gender
     */
    func setCueVoiceToDefault() {
        let langCode = AVSpeechSynthesisVoice.currentLanguageCode()
        if let defaultVoice = AVSpeechSynthesisVoice(language: langCode) {
            // For some reason, when you get a voice by language the gender is unspecified.
            // When you get the exact same voice by identifier it has a gender.
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
            
            self.cueVoiceOptions = VoiceOptions(voice.identifier)
        } else {
            self.cueVoiceOptions = VoiceOptions()
        }
        
    }
    
    func saveSpeakingOptions() {
        do {
            let encoder = JSONEncoder()
            
            let speakingVoiceEncoded = try encoder.encode(speakingVoiceOptions)
                        
            UserDefaults.standard.set(speakingVoiceEncoded, forKey: StorageKeys.speakingVoiceOptions)
        } catch {
            print("Failed to persist your settings")
        }
    }
    
    func saveCueOptions() {
        do {
            let encoder = JSONEncoder()
            
            let cueVoiceEncoded = try encoder.encode(cueVoiceOptions)
                        
            UserDefaults.standard.set(cueVoiceEncoded, forKey: StorageKeys.cueVoiceOptions)
        } catch {
            print("Failed to persist your settings")
        }
    }
    
    /***
     Save everything to user defaults
     */
    func save() {
        self.saveCueOptions()
        self.saveSpeakingOptions()
    }
}
