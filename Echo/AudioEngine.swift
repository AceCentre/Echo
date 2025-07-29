//
//  AudioEngine.swift
// Echo
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation
import AVKit
import SwiftUI

class AudioEngine: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()

    var callback: (() -> Void)?

    // iOS Bug Fix: Track if callback has been called to prevent multiple calls
    private var callbackCalled: Bool = false

    // iOS Bug Fix: Track current utterance to ignore old completions
    private var currentUtteranceText: String?

    // Cache voices to avoid repeated Assistant Framework calls
    private var voiceCache: [String: AVSpeechSynthesisVoice] = [:]

    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func stop() {

        self.callback = nil
        self.callbackCalled = true // Prevent any pending callbacks
        self.currentUtteranceText = nil // Clear current utterance tracking

        // Stop speech synthesis immediately
        self.synthesizer.stopSpeaking(at: .immediate)
        self.synthesizer.delegate = nil
        self.synthesizer = AVSpeechSynthesizer()
        self.synthesizer.delegate = self
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

        // Use direct speech synthesis for faster output - no more buffer-based approach

        // Set rate and volume directly for immediate speech
        let targetRate = isFast ? 75.0 : voiceOptions.rate
        let calculatedRate = Float((targetRate * 1.5) / 100 + 0.5)
        let clampedRate = max(AVSpeechUtteranceMinimumSpeechRate, min(AVSpeechUtteranceMaximumSpeechRate, calculatedRate))
        utterance.rate = clampedRate
        utterance.volume = Float(voiceOptions.volume) / 100

        // Use direct synthesis with pan handling for immediate output
        if pan != 0.0 {
            useSimpleSpeechWithAudioSessionPan(utterance: utterance, pan: pan)
        } else {
            synthesizer.speak(utterance)
        }
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

    // fallbackToDirectSynthesis method removed - no longer needed with direct speech synthesis

    // finished method removed - no longer needed with direct speech synthesis

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

    // AVAudioPlayerDelegate methods removed - no longer needed with direct speech synthesis

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
