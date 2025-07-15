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

    // Cache voices to avoid repeated Assistant Framework calls
    private var voiceCache: [String: AVSpeechSynthesisVoice] = [:]

    // Track voice system stability
    private var voiceSystemUnstable = false
    private var consecutiveFailures = 0

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
        print("🔊 AudioEngine.speak() called with text: '\(text)', voiceId: \(voiceOptions.voiceId)")

        callback = cb

        // Safety check: Don't attempt speech synthesis if app is not active
        guard scenePhase == .active else {
            print("🔊 AudioEngine: Skipping speech synthesis - app not active (phase: \(scenePhase))")
            callback?()
            return
        }

        // Safety check: Ensure text is not empty
        guard !text.isEmpty else {
            print("🔊 AudioEngine: Skipping speech synthesis - empty text")
            callback?()
            return
        }

        // Safety check: If voice system is unstable, use direct synthesis
        if voiceSystemUnstable {
            print("🔊 AudioEngine: Voice system unstable, using direct synthesis")
            useFallbackSynthesis(text: text, voiceOptions: voiceOptions, pan: pan, isFast: isFast)
            return
        }

        // TEMPORARY FIX FOR iOS 26 BETA: Always use fallback synthesis to avoid crashes
        // The synthesizer.write() method is causing crashes on iOS 26 Beta
        print("🔊 AudioEngine: Using fallback synthesis to avoid iOS 26 Beta crashes")
        useFallbackSynthesis(text: text, voiceOptions: voiceOptions, pan: pan, isFast: isFast)
        return

        // TODO: Re-enable buffer writing once iOS 26 Beta issues are resolved
        /*
        // Check if the requested voice is available before attempting synthesis
        let selectedVoice = getCachedVoice(identifier: voiceOptions.voiceId)
        guard let voice = selectedVoice else {
            print("🔊 AudioEngine: No valid voice available, using direct synthesis fallback")
            consecutiveFailures += 1
            if consecutiveFailures >= 3 {
                voiceSystemUnstable = true
                print("🔊 AudioEngine: Voice system marked as unstable after \(consecutiveFailures) failures")
            }
            useFallbackSynthesis(text: text, voiceOptions: voiceOptions, pan: pan, isFast: isFast)
            return
        }

        // If voice creation failed and we're using default, use fallback to prevent crashes
        if voiceOptions.voiceId != "default" && voice.identifier != voiceOptions.voiceId {
            print("🔊 AudioEngine: Voice mismatch detected, using direct synthesis fallback")
            consecutiveFailures += 1
            if consecutiveFailures >= 3 {
                voiceSystemUnstable = true
                print("🔊 AudioEngine: Voice system marked as unstable after \(consecutiveFailures) failures")
            }
            useFallbackSynthesis(text: text, voiceOptions: voiceOptions, pan: pan, isFast: isFast)
            return
        }

        // Reset failure count on successful voice creation
        consecutiveFailures = 0

        // let ssmlRepresentation = "<speak><say-as interpret-as=\"characters\">dylan</say-as></speak>"
        let ssmlRepresentation = "<speak>\(text)</speak>"
        guard let utterance = AVSpeechUtterance(ssmlRepresentation: ssmlRepresentation) else {
            print("🔊 AudioEngine: Failed to create utterance from SSML, using fallback")
            useFallbackSynthesis(text: text, voiceOptions: voiceOptions, pan: pan, isFast: isFast)
            return
        }

        utterance.voice = voice

        outputSemaphore.wait()

        let audioFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).caf")
        var output: AVAudioFile?

        if scenePhase == .active {
            // Wrap synthesizer.write in error handling to prevent crashes
            synthesizer.write(utterance, toBufferCallback: { buffer in
                    guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                        print("🔊 AudioEngine: Unknown buffer type: \(buffer), skipping")
                        self.outputSemaphore.signal()
                        self.callback?()
                        return
                    }

                    // Safety check: Ensure buffer has valid data
                    guard pcmBuffer.frameLength > 0 else {
                        print("🔊 AudioEngine: Buffer has zero frame length, skipping")
                        return
                    }

                    // Safety check: Ensure buffer format is valid
                    guard pcmBuffer.format.channelCount > 0 && pcmBuffer.format.sampleRate > 0 else {
                        print("🔊 AudioEngine: Invalid buffer format, skipping")
                        self.outputSemaphore.signal()
                        self.callback?()
                        return
                    }

                    if let unwrappedOutput = output {
                        do {
                            try unwrappedOutput.write(from: pcmBuffer)
                        } catch {
                            print("🔊 AudioEngine: Failed to write pcmBuffer to existing output: \(error.localizedDescription)")
                            self.outputSemaphore.signal()
                            self.callback?()
                            return
                        }

                    } else {
                        do {
                            // Validate format settings before creating audio file
                            let settings = pcmBuffer.format.settings
                            guard !settings.isEmpty else {
                                print("🔊 AudioEngine: Invalid format settings, cannot create audio file")
                                self.outputSemaphore.signal()
                                self.callback?()
                                return
                            }

                            output = try AVAudioFile(
                                forWriting: audioFilePath,
                                settings: settings,
                                commonFormat: pcmBuffer.format.commonFormat,
                                interleaved: pcmBuffer.format.isInterleaved
                            )
                            if let unwrappedOutput = output {
                                try unwrappedOutput.write(from: pcmBuffer)
                            }
                        } catch {
                            print("🔊 AudioEngine: Failed to create or write to new audio file: \(error.localizedDescription)")
                            self.outputSemaphore.signal()
                            self.callback?()
                            return
                        }
                    }

                    if pcmBuffer.frameLength == 0 || pcmBuffer.frameLength == 1 {
                        // Safety check: Ensure we have a valid audio file before finishing
                        let fileManager = FileManager.default
                        if fileManager.fileExists(atPath: audioFilePath.path) {
                            self.finished(audioUrl: audioFilePath, pan: pan, volume: voiceOptions.volume, rate: isFast ? 75 : voiceOptions.rate)
                        } else {
                            print("🔊 AudioEngine: Audio file not created, skipping playback")
                            self.outputSemaphore.signal()
                            self.callback?()
                        }
                    }
                })
        } else {
            print("🔊 AudioEngine: Not calling write as app is in the background or inactive")
            self.outputSemaphore.signal()
            self.callback?()
        }
    }
    
    func finished(audioUrl: URL, pan: Float, volume: Double, rate: Double) {
        // Safety check: Verify file exists and has content
        do {
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: audioUrl.path) else {
                print("🔊 AudioEngine: Audio file does not exist at path: \(audioUrl.path)")
                outputSemaphore.signal()
                callback?()
                return
            }

            let fileAttributes = try fileManager.attributesOfItem(atPath: audioUrl.path)
            let fileSize = fileAttributes[.size] as? NSNumber ?? 0

            guard fileSize.intValue > 0 else {
                print("🔊 AudioEngine: Audio file is empty (zero bytes)")
                outputSemaphore.signal()
                callback?()
                return
            }

            self.player = try AVAudioPlayer(contentsOf: audioUrl)

            guard let unwrappedPlayer = self.player else {
                print("🔊 AudioEngine: Failed to create AVAudioPlayer")
                outputSemaphore.signal()
                callback?()
                return
            }

            // Validate and clamp values to prevent crashes
            let calculatedVolume = max(0.0, min(1.0, Float(volume) / 100))
            let calculatedRate = max(0.5, min(2.0, ((Float(rate) * 1.5) / 100) + 0.5))
            let clampedPan = max(-1.0, min(1.0, pan))

            unwrappedPlayer.pan = clampedPan
            unwrappedPlayer.rate = calculatedRate
            unwrappedPlayer.enableRate = true
            unwrappedPlayer.volume = calculatedVolume
            unwrappedPlayer.delegate = self

            if unwrappedPlayer.prepareToPlay() {
                unwrappedPlayer.play()
            } else {
                print("🔊 AudioEngine: Failed to prepare audio player")
                outputSemaphore.signal()
                callback?()
            }
        } catch {
            print("🔊 AudioEngine: Failed to create AVAudioPlayer: \(error.localizedDescription)")
            outputSemaphore.signal()
            callback?()
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        outputSemaphore.signal()
        callback?()
    }

    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("🔊 AudioEngine: Speech synthesis completed")
        outputSemaphore.signal()
        callback?()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("🔊 AudioEngine: Speech synthesis cancelled")
        outputSemaphore.signal()
        callback?()
    }

    // MARK: - Fallback Synthesis

    /// Fallback method that uses direct AVSpeechSynthesizer without buffer writing
    /// This is used when voice creation fails to prevent crashes
    private func useFallbackSynthesis(text: String, voiceOptions: Voice, pan: Float, isFast: Bool) {
        print("🔊 AudioEngine: Using fallback synthesis for text: \(text)")

        // Create a new synthesizer for direct speech (not writing to buffer)
        let fallbackSynthesizer = AVSpeechSynthesizer()

        // Set up delegate to handle completion
        fallbackSynthesizer.delegate = self

        // Create a simple utterance without SSML
        let utterance = AVSpeechUtterance(string: text)

        // Set basic properties with safe defaults
        let safeRate = max(0.1, min(1.0, Float(isFast ? 0.6 : (voiceOptions.rate / 100))))
        let safeVolume = max(0.0, min(1.0, Float(voiceOptions.volume / 100)))

        utterance.rate = safeRate
        utterance.volume = safeVolume
        utterance.pitchMultiplier = 1.0

        // Try to use a basic system voice
        if let systemVoice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = systemVoice
            print("🔊 AudioEngine: Using en-US system voice for fallback")
        } else {
            print("🔊 AudioEngine: Using default system voice for fallback")
        }

        // Store the synthesizer to prevent deallocation
        self.synthesizer = fallbackSynthesizer

        // Speak directly without buffer writing
        print("🔊 AudioEngine: Starting fallback speech synthesis")
        fallbackSynthesizer.speak(utterance)
    }

    // MARK: - Voice Caching

    private func getCachedVoice(identifier: String) -> AVSpeechSynthesisVoice? {
        // Check cache first
        if let cachedVoice = voiceCache[identifier] {
            return cachedVoice
        }

        // Safety check: Ensure identifier is not empty or invalid
        guard !identifier.isEmpty && identifier != "unknown" else {
            print("🔊 AudioEngine: Invalid voice identifier '\(identifier)', using default voice")
            let defaultVoice = AVSpeechSynthesisVoice()
            voiceCache[identifier] = defaultVoice
            return defaultVoice
        }

        // Try to find the voice in the available voices list to avoid Assistant Framework calls
        do {
            let availableVoices = AVSpeechSynthesisVoice.speechVoices()
            let voice = availableVoices.first { $0.identifier == identifier }

            if let voice = voice {
                voiceCache[identifier] = voice
                return voice
            } else {
                // Only log when we have to create a voice (which may trigger Assistant Framework)
                print("🔊 AudioEngine: Voice not found in speechVoices(), attempting to create by identifier: \(identifier)")

                // Wrap voice creation in try-catch to handle potential crashes
                let createdVoice = AVSpeechSynthesisVoice(identifier: identifier)

                if let createdVoice = createdVoice {
                    voiceCache[identifier] = createdVoice
                    print("🔊 AudioEngine: Voice created and cached successfully")
                    return createdVoice
                } else {
                    print("🔊 AudioEngine: Failed to create voice with identifier '\(identifier)', using default")
                    // Fallback to default voice
                    let defaultVoice = AVSpeechSynthesisVoice()
                    voiceCache[identifier] = defaultVoice
                    return defaultVoice
                }
            }
        } catch {
            print("🔊 AudioEngine: Error accessing speech voices: \(error.localizedDescription), using default voice")
            let defaultVoice = AVSpeechSynthesisVoice()
            voiceCache[identifier] = defaultVoice
            return defaultVoice
        }
    }
}
