//
//  SynthEngine.swift
//  Echo
//
//  Created by Gavin Henderson on 18/01/2024.
//

import Foundation
import AVKit

/***
 @deprecated
 Note this class is not used. It was used originally as the voice engine but it didn't support pan. See AudioEngine for udated version
 */
class SynthesiserEngine: NSObject, AudioEngineProtocol, AVSpeechSynthesizerDelegate {
    var synthesizer = AVSpeechSynthesizer()
    
    var callback: (() -> Void)?
    
    var lastIssuedUtterance: AVSpeechUtterance?
    
    override init() {
        super.init()
        self.synthesizer.delegate = self
    }
    
    func stop() {
        self.synthesizer.stopSpeaking(at: .immediate)
    }
    
    func speak(text: String, voiceOptions: VoiceOptions, pan: Float, cb: (() -> Void)?) {
        let utterance = AVSpeechUtterance(string: text)
        
        utterance.voice = AVSpeechSynthesisVoice(identifier: voiceOptions.voiceId)
        utterance.pitchMultiplier = ((voiceOptions.pitch * 1.5) / 100) + 0.5 // Pitch is between 0.5 - 2
        utterance.volume = voiceOptions.volume / 100 // Volume is between 0 - 1
        utterance.rate = voiceOptions.rate / 100 // Rate is between 0 - 1
        
        self.lastIssuedUtterance = utterance
        
        // AVAudioSession.sharedInstance().setCategory(.playback, options: [.])
        
        if cb != nil {
            self.callback = cb
        }
        
        self.synthesizer.speak(utterance)
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
