//
//  VoiceEngine.swift
//  Echo
//
//  Created by Gavin Henderson on 03/10/2023.
//

import Foundation
import AVKit
import SharedEcho

class VoiceOptions: Codable {
    var voiceId: String
    var rate: Float
    var pitch: Float
    var volume: Float
        
    init() {
        self.voiceId = ""
        self.rate = 50
        self.pitch = 25
        self.volume = 100
    }
    
    init(
        voiceId: String,
        rate: Float,
        pitch: Float,
        volume: Float
    ) {
        self.voiceId = voiceId
        self.rate = rate
        self.pitch = pitch
        self.volume = volume
    }
    
    init(_ voiceId: String) {
        self.voiceId = voiceId
        self.rate = 50
        self.pitch = 25
        self.volume = 100
    }
}

class VoiceEngine: NSObject, ObservableObject, AVSpeechSynthesizerDelegate, Analytic {
    @Published var speakingVoiceOptions: VoiceOptions = VoiceOptions()
    @Published var cueVoiceOptions: VoiceOptions = VoiceOptions()
    
    var analytics: Analytics?
    
    var synthesizer = AVSpeechSynthesizer()
    
    var callback: (() -> Void)?
    
    var lastIssuedUtterance: AVSpeechUtterance?
    
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
    
    override init() {
        super.init()
        self.synthesizer.delegate = self
        
        // This makes it work in silent mode by setting the audio to playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        } catch let error {
            print("This error message from SpeechSynthesizer \(error.localizedDescription)")
        }
    }
    
    func play(_ text: String, voiceOptions: VoiceOptions, cb: (() -> Void)? = {}) {
        let textWithSpaces = text.replacingOccurrences(of: "·", with: " ")
        let utterance = AVSpeechUtterance(string: textWithSpaces)
        
        utterance.voice = AVSpeechSynthesisVoice(identifier: voiceOptions.voiceId)
        utterance.pitchMultiplier = ((voiceOptions.pitch * 1.5) / 100) + 0.5 // Pitch is between 0.5 - 2
        utterance.volume = voiceOptions.volume / 100 // Volume is between 0 - 1
        utterance.rate = voiceOptions.rate / 100 // Rate is between 0 - 1

        self.synthesizer.stopSpeaking(at: .immediate)
        
        if cb != nil {
            self.callback = cb
        }
        
        lastIssuedUtterance = utterance
        self.synthesizer.speak(utterance)
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
        self.analytics = analytics
        
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
    
    func triggerCallback(utterance: AVSpeechUtterance) {   
        if utterance == lastIssuedUtterance {
            if let unwappedCallback = self.callback {
                unwappedCallback()
            }
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        triggerCallback(utterance: utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        triggerCallback(utterance: utterance)
    }
}
