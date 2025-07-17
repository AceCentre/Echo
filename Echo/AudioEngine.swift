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

    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    func stop() {
        let timestamp = Date().timeIntervalSince1970
        //print("🔊 AUDIO ENGINE STOP CALLED: [\(timestamp)]")

        self.callback = nil
        self.callbackCalled = true // Prevent any pending callbacks
        self.currentUtteranceText = nil // Clear current utterance tracking

        // iOS Bug Fix: stopSpeaking() doesn't work reliably - recreate synthesizer
        self.synthesizer.stopSpeaking(at: .immediate)
        self.synthesizer.delegate = nil
        self.synthesizer = AVSpeechSynthesizer()
        self.synthesizer.delegate = self
        // print("🔊 AUDIO ENGINE: Recreated synthesizer to force stop")

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
            let timestamp = Date().timeIntervalSince1970
            // print("🔊 AUDIO ENGINE: Prevented duplicate callback at [\(timestamp)]")
            return
        }
        callbackCalled = true
        callback?()
    }
    
    func speak(text: String, voiceOptions: Voice, pan: Float, scenePhase: ScenePhase, isFast: Bool = false, cb: (() -> Void)?) {
        let timestamp = Date().timeIntervalSince1970
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
        let ssmlRepresentation = "<speak>\(escapeXML(text))</speak>"

        if let ssmlUtterance = AVSpeechUtterance(ssmlRepresentation: ssmlRepresentation) {
            utterance = ssmlUtterance
        } else {
            // Fallback to plain text if SSML fails (iOS 26 compatibility)
            print("🔊 SSML failed, using plain text fallback")
            utterance = AVSpeechUtterance(string: text)
        }

        // Set the voice just before synthesis to minimize Assistant Framework calls
        let selectedVoice = getCachedVoice(identifier: voiceOptions.voiceId)
        utterance.voice = selectedVoice

        // Set speech parameters directly on utterance
        utterance.rate = Float((isFast ? 75 : voiceOptions.rate) * 1.5 / 100 + 0.5)
        utterance.volume = Float(voiceOptions.volume) / 100

        // iOS 26 Beta Fix: NEVER use synthesizer.write() - it causes crashes on iOS 26
        // For panning, we'll use a different approach that doesn't involve write()
        if pan != 0.0 {
            //print("🔊 AUDIO ENGINE: Using pan approach for '\(text)'")
            useSimpleSpeechWithAudioSessionPan(utterance: utterance, pan: pan)
        } else {
            // print("🔊 AUDIO ENGINE: Calling synthesizer.speak() for '\(text)'")
            synthesizer.speak(utterance)
        }
    }

    private func useSimpleSpeechWithAudioSessionPan(utterance: AVSpeechUtterance, pan: Float) {
        // iOS 26 Beta Fix: Use AVAudioSession channel routing instead of synthesizer.write()

        // Configure audio session for channel routing
        configureAudioSessionForPanning(pan: pan)

        // Use simple speech synthesis (iOS 26 compatible)
        synthesizer.speak(utterance)
    }

    private func configureAudioSessionForPanning(pan: Float) {
        // iOS 26 Beta Fix: Don't try to reconfigure audio session - it causes warnings
        // and iOS doesn't support direct channel routing through AVAudioSession anyway

        if pan < 0 {
            print("🔊 LEFT channel requested - use hardware audio splitter cable")
        } else if pan > 0 {
            print("🔊 RIGHT channel requested - use hardware audio splitter cable")
        }

        //print("🔊 INFO: Audio channel splitting requires physical audio splitter cable")
        //print("🔊 INFO: iOS 26 Beta limitation prevents software-based channel routing")
    }
    


    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        let timestamp = Date().timeIntervalSince1970
        //print("🔊 AUDIO ENGINE FINISH: [\(timestamp)] '\(utterance.speechString)'")

        // iOS Bug Fix: Only process completion if this matches our current utterance
        guard utterance.speechString == currentUtteranceText else {
            // print("🔊 AUDIO ENGINE: Ignoring completion for old utterance: '\(utterance.speechString)'")
            return
        }

        safeCallback()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let timestamp = Date().timeIntervalSince1970
        print("🔊 AUDIO ENGINE CANCEL: [\(timestamp)] '\(utterance.speechString)'")

        // iOS Bug Fix: Only process cancellation if this matches our current utterance
        guard utterance.speechString == currentUtteranceText else {
            // print("🔊 AUDIO ENGINE: Ignoring cancellation for old utterance: '\(utterance.speechString)'")
            return
        }

        safeCallback()
    }

    // MARK: - AVAudioPlayerDelegate

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully: Bool) {
        audioFile = nil // Clean up
        safeCallback()
    }

    // MARK: - Voice Caching

    private func getCachedVoice(identifier: String) -> AVSpeechSynthesisVoice? {
        // Handle empty identifier (system default)
        if identifier.isEmpty {
            print("🔊 Using system default voice")
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
            print("🔊 Voice not found in speechVoices(), creating by identifier: \(identifier)")
            let createdVoice = AVSpeechSynthesisVoice(identifier: identifier)

            if let createdVoice = createdVoice {
                voiceCache[identifier] = createdVoice
                print("🔊 DEBUG: Voice created and cached successfully")
                return createdVoice
            } else {
                print("🔊 DEBUG: Failed to create voice, using fallback")
                // iOS 26 Fix: Use proper fallback voice creation
                let defaultVoice = createFallbackVoice()
                if let defaultVoice = defaultVoice {
                    voiceCache[identifier] = defaultVoice
                    return defaultVoice
                } else {
                    print("🔊 ERROR: Could not create any fallback voice")
                    return nil
                }
            }
        }
    }

    private func createFallbackVoice() -> AVSpeechSynthesisVoice? {
        // Try multiple fallback strategies for iOS 26 compatibility

        // 1. Try Alex voice (usually available on all iOS versions)
        if let alexVoice = AVSpeechSynthesisVoice(identifier: AVSpeechSynthesisVoiceIdentifierAlex) {
            print("🔊 Using Alex voice as fallback")
            return alexVoice
        }

        // 2. Try to get any English voice
        let availableVoices = AVSpeechSynthesisVoice.speechVoices()
        if let englishVoice = availableVoices.first(where: { $0.language.hasPrefix("en") }) {
            print("🔊 Using English voice as fallback: \(englishVoice.name)")
            return englishVoice
        }

        // 3. Try to get the first available voice
        if let firstVoice = availableVoices.first {
            print("🔊 Using first available voice as fallback: \(firstVoice.name)")
            return firstVoice
        }

        // 4. Last resort: try creating with language code
        if let languageVoice = AVSpeechSynthesisVoice(language: "en-US") {
            print("🔊 Using language-based voice as fallback")
            return languageVoice
        }

        print("🔊 CRITICAL: No fallback voice could be created")
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
