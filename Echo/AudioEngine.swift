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

    // For temporary audio file creation during pan operations
    private var audioFile: AVAudioFile?

    var callback: (() -> Void)?

    // iOS Bug Fix: Track if callback has been called to prevent multiple calls
    private var callbackCalled: Bool = false

    // iOS Bug Fix: Track current utterance to ignore old completions
    private var currentUtteranceText: String?

    // Cache voices to avoid repeated Assistant Framework calls
    private var voiceCache: [String: AVSpeechSynthesisVoice] = [:]

    // Track audio buffer failures for recovery
    private var consecutiveBufferFailures: Int = 0
    private let maxBufferFailures: Int = 3

    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func stop() {

        self.callback = nil
        self.callbackCalled = true // Prevent any pending callbacks
        self.currentUtteranceText = nil // Clear current utterance tracking

        // iOS Bug Fix: stopSpeaking() doesn't work reliably - recreate synthesizer
        self.synthesizer.stopSpeaking(at: .immediate)
        self.synthesizer.delegate = nil
        self.synthesizer = AVSpeechSynthesizer()
        self.synthesizer.delegate = self


        // Stop player if it exists
        if let unwrappedPlayer = self.player {
            unwrappedPlayer.pause()
            unwrappedPlayer.stop()
        }

        // Clean up audio file
        audioFile = nil
    }

    // iOS Bug Fix: Safe callback that prevents multiple calls
    private func safeCallback() {
        guard !callbackCalled else {
            return
        }
        callbackCalled = true
        callback?()
    }
    
    func speak(text: String, voiceOptions: Voice, pan: Float, scenePhase: ScenePhase, isFast: Bool = false, cb: (() -> Void)?) {
        //let timestamp = Date().timeIntervalSince1970
        // print("🔊 AUDIO ENGINE SPEAK START: [\(timestamp)] '\(text)' voice: \(voiceOptions.voiceName)")

        callback = cb
        callbackCalled = false // Reset callback flag for new speech
        currentUtteranceText = text // Track current utterance

        guard scenePhase == .active else {
            // print("🔊 AUDIO ENGINE: Not speaking as app is in the background or inactive")
            safeCallback()
            return
        }

        // Try SSML first, fallback to plain text for iOS 26 compatibility
        let utterance: AVSpeechUtterance

        // Check if text already contains SSML markup
        let containsSSML = text.contains("<") && text.contains(">")
        let ssmlRepresentation: String

        if containsSSML {
            // Text already contains SSML, wrap in speak tags without escaping
            ssmlRepresentation = "<speak>\(text)</speak>"
        } else {
            // Plain text, escape and wrap in speak tags
            ssmlRepresentation = "<speak>\(escapeXML(text))</speak>"
        }

        if let ssmlUtterance = AVSpeechUtterance(ssmlRepresentation: ssmlRepresentation) {
            utterance = ssmlUtterance
        } else {
            // Fallback to plain text if SSML fails (iOS 26 compatibility)
            EchoLogger.debug("SSML failed, using plain text fallback", category: .voice)
            utterance = AVSpeechUtterance(string: text)
        }

        // Set the voice just before synthesis to minimize Assistant Framework calls
        let selectedVoice = getCachedVoice(identifier: voiceOptions.voiceId)
        utterance.voice = selectedVoice

        // Since iOS 26 beta has fixed the file writing issue, use file-based approach for proper rate/volume control

        // Use normal rate for synthesis, we'll control rate with AVAudioPlayer
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.volume = 1.0

        // Generate audio to file first, then play with rate/volume control
        let audioFilePath = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).caf")
        var output: AVAudioFile?
        var hasFinished = false

        var bufferCount = 0
        var hasValidAudio = false

        // Add timeout to prevent hanging on buffer generation
        let timeoutTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            if !hasFinished {
                hasFinished = true
                DispatchQueue.main.async {
                    EchoLogger.warning("Audio buffer generation timed out, falling back to direct synthesis", category: .voice)
                    self.fallbackToDirectSynthesis(text: text, pan: pan, voiceOptions: voiceOptions, isFast: isFast)
                }
            }
        }

        synthesizer.write(utterance, toBufferCallback: { buffer in
            guard !hasFinished else {
                timeoutTimer.invalidate()
                return
            }
            bufferCount += 1

            guard let pcmBuffer = buffer as? AVAudioPCMBuffer else {
                EchoLogger.error("Unknown buffer type: \(buffer)", category: .voice)
                return
            }

            // Check for empty buffer (iOS 26 beta bug) and invalid data
            if pcmBuffer.frameLength > 1 && pcmBuffer.audioBufferList.pointee.mBuffers.mDataByteSize > 0 {
                hasValidAudio = true
            } else if pcmBuffer.audioBufferList.pointee.mBuffers.mDataByteSize == 0 {
                // Log the specific buffer issue we're seeing in the logs
                EchoLogger.warning("Detected zero-size audio buffer (mDataByteSize = 0), this may cause audio issues", category: .voice)
            }

            if let unwrappedOutput = output {
                do {
                    try unwrappedOutput.write(from: pcmBuffer)
                } catch {
                    EchoLogger.error("Failed to write pcmBuffer to output: \(error)", category: .voice)
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
                        EchoLogger.error("Failed to write pcmBuffer to output: \(error)", category: .voice)
                    }
                }
            }

            if pcmBuffer.frameLength == 0 || pcmBuffer.frameLength == 1 {
                hasFinished = true
                timeoutTimer.invalidate()
                DispatchQueue.main.async {
                    if hasValidAudio {
                        // Reset failure counter on success
                        self.consecutiveBufferFailures = 0
                        self.finished(audioUrl: audioFilePath, pan: pan, volume: voiceOptions.volume, rate: isFast ? 75 : voiceOptions.rate)
                    } else {
                        // Track buffer failures and potentially reset audio system
                        self.consecutiveBufferFailures += 1
                        EchoLogger.warning("File-based synthesis produced no valid audio (failure #\(self.consecutiveBufferFailures)), falling back to direct synthesis", category: .voice)

                        // If we have too many consecutive failures, suggest audio session reset
                        if self.consecutiveBufferFailures >= self.maxBufferFailures {
                            EchoLogger.error("Multiple consecutive audio buffer failures detected. Audio session may need reset.", category: .voice)
                            self.consecutiveBufferFailures = 0 // Reset counter
                        }

                        self.fallbackToDirectSynthesis(text: text, pan: pan, voiceOptions: voiceOptions, isFast: isFast)
                    }
                }
            }
        })
    }

    func speakDirect(text: String, voiceOptions: Voice, pan: Float, scenePhase: ScenePhase, cb: (() -> Void)?) {
        callback = cb
        callbackCalled = false
        currentUtteranceText = text

        guard scenePhase == .active else {
            safeCallback()
            return
        }

        let utterance = AVSpeechUtterance(string: text)

        // Set voice
        let selectedVoice = getCachedVoice(identifier: voiceOptions.voiceId)
        utterance.voice = selectedVoice

        // Set rate and volume directly
        let targetRate = Float(voiceOptions.rate)
        let calculatedRate = Float((targetRate * 1.5) / 100 + 0.5)
        let clampedRate = max(AVSpeechUtteranceMinimumSpeechRate, min(AVSpeechUtteranceMaximumSpeechRate, calculatedRate))
        utterance.rate = clampedRate
        utterance.volume = Float(voiceOptions.volume) / 100

        // Use direct synthesis with pan handling
        if pan != 0.0 {
            useSimpleSpeechWithAudioSessionPan(utterance: utterance, pan: pan)
        } else {
            synthesizer.speak(utterance)
        }
    }

    func fallbackToDirectSynthesis(text: String, pan: Float, voiceOptions: Voice, isFast: Bool) {
        let utterance = AVSpeechUtterance(string: text)
        let selectedVoice = getCachedVoice(identifier: voiceOptions.voiceId)
        utterance.voice = selectedVoice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.volume = 1.0

        if pan != 0.0 {
            useSimpleSpeechWithAudioSessionPan(utterance: utterance, pan: pan)
        } else {
            synthesizer.speak(utterance)
        }
    }

    func finished(audioUrl: URL, pan: Float, volume: Double, rate: Double) {
        do {
            self.player = try AVAudioPlayer(contentsOf: audioUrl)

            guard let unwrappedPlayer = self.player else {
                EchoLogger.error("Failed to create AVAudioPlayer", category: .voice)
                safeCallback()
                return
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
            safeCallback()
        }
    }

    private func useSimpleSpeechWithAudioSessionPan(utterance: AVSpeechUtterance, pan: Float) {

        // Configure audio session for channel routing
        configureAudioSessionForPanning(pan: pan)

        // Use simple speech synthesis (iOS 26 compatible)
        synthesizer.speak(utterance)
    }

    private func configureAudioSessionForPanning(pan: Float) {
        if pan < 0 {
            EchoLogger.debug("LEFT channel requested - use hardware audio splitter cable", category: .voice)
        } else if pan > 0 {
            EchoLogger.debug("RIGHT channel requested - use hardware audio splitter cable", category: .voice)
        }

    }
    


    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        // iOS Bug Fix: Only process completion if this matches our current utterance
        guard utterance.speechString == currentUtteranceText else {
            return
        }

        safeCallback()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        EchoLogger.debug("Audio engine cancelled utterance: '\(utterance.speechString)'", category: .voice)

        // iOS Bug Fix: Only process cancellation if this matches our current utterance
        guard utterance.speechString == currentUtteranceText else {
            return
        }

        safeCallback()
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        audioFile = nil // Clean up
        safeCallback()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        safeCallback()
    }

    // MARK: - Voice Caching

    private func getCachedVoice(identifier: String) -> AVSpeechSynthesisVoice? {
        // Handle empty identifier (system default)
        if identifier.isEmpty {
            EchoLogger.debug("Using system default voice", category: .voice)
            return nil // nil means use system default
        }

        // Check cache first
        if let cachedVoice = voiceCache[identifier] {
            return cachedVoice
        }

        // Try to find the voice in the available voices list to avoid Assistant Framework calls
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        let voice = availableVoices.first { $0.identifier == identifier }

        if let voice = voice {
            voiceCache[identifier] = voice
            return voice
        } else {
            // Only log when we have to create a voice (which may trigger Assistant Framework)
            EchoLogger.debug("Voice not found in speechVoices(), creating by identifier: \(identifier)", category: .voice)
            let createdVoice = AVSpeechSynthesisVoice(identifier: identifier)

            if let createdVoice = createdVoice {
                voiceCache[identifier] = createdVoice
                return createdVoice
            } else {
                EchoLogger.debug("Failed to create voice, using fallback", category: .voice)
                // iOS 26 Fix: Use proper fallback voice creation
                let defaultVoice = createFallbackVoice()
                if let defaultVoice = defaultVoice {
                    voiceCache[identifier] = defaultVoice
                    return defaultVoice
                } else {
                    EchoLogger.error("Could not create any fallback voice", category: .voice)
                    return nil
                }
            }
        }
    }

    private func createFallbackVoice() -> AVSpeechSynthesisVoice? {
        // Try multiple fallback strategies for iOS 26 compatibility

        // 1. Try Alex voice (usually available on all iOS versions)
        if let alexVoice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex) {
            EchoLogger.debug("Using Alex voice as fallback", category: .voice)
            return alexVoice
        }

        // 2. Try to get any English voice
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        if let englishVoice = availableVoices.first(where: { $0.language.hasPrefix("en") }) {
            EchoLogger.debug("Using English voice as fallback: \(englishVoice.name)", category: .voice)
            return englishVoice
        }

        // 3. Try to get the first available voice
        if let firstVoice = availableVoices.first {
            EchoLogger.debug("Using first available voice as fallback: \(firstVoice.name)", category: .voice)
            return firstVoice
        }

        // 4. Last resort: try creating with language code
        if let languageVoice = AVSpeechSynthesisVoice(language: "en-US") {
            EchoLogger.debug("Using language-based voice as fallback", category: .voice)
            return languageVoice
        }

        EchoLogger.error("No fallback voice could be created", category: .voice)
        return nil
    }

    private func escapeXML(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}
