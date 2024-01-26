//
//  AudioEngine.swift
//  Echo
//
//  Created by Gavin Henderson on 18/01/2024.
//

import Foundation
import AVKit

class AudioEngine: NSObject, AudioEngineProtocol, AVSpeechSynthesizerDelegate, AVAudioPlayerDelegate {
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
    
    func speak(text: String, voiceOptions: VoiceOptions, cb: (() -> Void)?) {
        callback = cb
        
        let utterance = AVSpeechUtterance(string: text)
        
        print(utterance.speechString)
        
        utterance.voice = AVSpeechSynthesisVoice(identifier: voiceOptions.voiceId)
        utterance.pitchMultiplier = ((voiceOptions.pitch * 1.5) / 100) + 0.5 // Pitch is between 0.5 - 2
        utterance.volume = voiceOptions.volume / 100 // Volume is between 0 - 1
        utterance.rate = voiceOptions.rate / 100 // Rate is between 0 - 1
                
        outputSemaphore.wait()
        
        let audioFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).caf")
        var output: AVAudioFile?
        
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
                self.finished(audioUrl: audioFilePath)
            }
        })
    }
    
    func finished(audioUrl: URL) {
        do {
            self.player = try AVAudioPlayer(contentsOf: audioUrl)
            self.player?.delegate = self
            self.player?.prepareToPlay()
            self.player?.play()
        } catch {
            fatalError("Failed to create AVAudioPlayer")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        outputSemaphore.signal()
        callback?()
    }
}
