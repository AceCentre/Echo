//
//  AudioEngine.swift
// Echo
//
//  Created by Gavin Henderson on 29/05/2024.
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
        self.callback = nil
        self.synthesizer.stopSpeaking(at: .immediate)
        if let unwrappedPlayer = self.player {
            unwrappedPlayer.pause()
            unwrappedPlayer.stop()
        }
        
        outputSemaphore.signal()
    }
    
    func speak(text: String, voiceOptions: Voice, pan: Float, scenePhase: ScenePhase, isFast: Bool = false, cb: (() -> Void)?) {
        callback = cb
                
        // let ssmlRepresentation = "<speak><say-as interpret-as=\"characters\">dylan</say-as></speak>"
        let ssmlRepresentation = "<speak>\(text)</speak>"
        guard let utterance = AVSpeechUtterance(ssmlRepresentation: ssmlRepresentation) else {
            fatalError("SSML was not valid")
        }
        
        utterance.voice = AVSpeechSynthesisVoice(identifier: voiceOptions.voiceId)
        
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
                    self.finished(audioUrl: audioFilePath, pan: pan, volume: voiceOptions.volume, rate: isFast ? 75 : voiceOptions.rate)
                }
            })
        } else {
            print("Not calling write as app is in the background or inactive")
        }
    }
    
    func finished(audioUrl: URL, pan: Float, volume: Double, rate: Double) {
        do {
            self.player = try AVAudioPlayer(contentsOf: audioUrl)
            
            guard let unwrappedPlayer = self.player else {
                fatalError("Failed to create AVAudioPlayer")
            }
            
            let calculatedVolume = Float(volume) / 100
            let calculatedRate = ((Float(rate) * 1.5) / 100) + 0.5

            unwrappedPlayer.pan = pan
            unwrappedPlayer.rate = calculatedRate
            unwrappedPlayer.enableRate = true
            unwrappedPlayer.volume = calculatedVolume
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
