//
//  AudioEngine.swift
//  Echo
//
//  Created by Gavin Henderson on 18/01/2024.
//

import Foundation
import AVKit
import SwiftUI

class AudioEngine: NSObject, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate, ObservableObject {
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    var player: AVAudioPlayer?
            
    var callback: (() -> Void)?
    
    // Use a semaphore to make sure only one thing is writing to the output file at a time.
    var outputSemaphore: DispatchSemaphore

    override init() {
        outputSemaphore = DispatchSemaphore(value: 1)

        super.init()
        
        synthesizer.delegate = self
    }
    
    func stop() {
        if let unwrappedPlayer = self.player {
            unwrappedPlayer.pause()
            unwrappedPlayer.stop()
        }
        
        self.synthesizer.stopSpeaking(at: .immediate)
        self.callback = nil
        
        outputSemaphore.signal()
    }
    
    func speak(text: String, voiceOptions: VoiceOptions, pan: Float, scenePhase: ScenePhase, cb: (() -> Void)?) {
        callback = cb
                
        // let ssmlRepresentation = "<speak><say-as interpret-as=\"characters\">dylan</say-as></speak>"
        let ssmlRepresentation = "<speak>\(text)</speak>"
        guard let utterance = AVSpeechUtterance(ssmlRepresentation: ssmlRepresentation) else {
            fatalError("SSML was not valid")
        }
        
        utterance.voice = AVSpeechSynthesisVoice(identifier: voiceOptions.voiceId)
        utterance.pitchMultiplier = ((voiceOptions.pitch * 1.5) / 100) + 0.5 // Pitch is between 0.5 - 2
        utterance.volume = voiceOptions.volume / 100 // Volume is between 0 - 1
        utterance.rate = voiceOptions.rate / 100 // Rate is between 0 - 1
                
        outputSemaphore.wait()
        
        let audioFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).caf")
        var output: AVAudioFile?
            
        if scenePhase == .active {
            synthesizer.write(utterance, toBufferCallback: { buffer in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                    fatalError("unknown buffer type: \(buffer)")
                }
                
                if let unwrappedOutput = output {
                    do {
                        try unwrappedOutput.write(from: pcmBuffer)
                    } catch {
                        fatalError("Failed to write pcmBuffer to output")
                    }
                    
                } else {
                    output = try? AVAudioFile(
                        forWriting: audioFilePath,
                        settings: pcmBuffer.format.settings,
                        commonFormat: pcmBuffer.format.commonFormat,
                        interleaved: pcmBuffer.format.isInterleaved
                    )
                    if let unwrappedOutput = output {
                        do {
                            try unwrappedOutput.write(from: pcmBuffer)
                        } catch {
                            fatalError("Failed to write pcmBuffer to output")
                        }
                    }
                }
                
                if pcmBuffer.frameLength == 0 || pcmBuffer.frameLength == 1 {
                    self.finished(audioUrl: audioFilePath, pan: pan)
                }
            })
        } else {
            print("Not calling write as app is in the background or inactive")
        }
    }
    
    func finished(audioUrl: URL, pan: Float) {
        do {
            self.player = try AVAudioPlayer(contentsOf: audioUrl)
            
            guard let unwrappedPlayer = self.player else {
                fatalError("Failed to create AVAudioPlayer")
            }
            
            unwrappedPlayer.pan = pan
            unwrappedPlayer.delegate = self
            unwrappedPlayer.prepareToPlay()
            unwrappedPlayer.play()
        } catch {
            fatalError("Failed to create AVAudioPlayer")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        outputSemaphore.signal()
        callback?()
    }
}
