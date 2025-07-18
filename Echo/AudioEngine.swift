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
        //EchoLogger.debug("AUDIO ENGINE STOP CALLED: [\(Date().timeIntervalSince1970)]", category: .voice)

        self.callback = nil
        self.callbackCalled = true // Prevent any pending callbacks
        self.currentUtteranceText = nil // Clear current utterance tracking

        // iOS Bug Fix: stopSpeaking() doesn't work reliably - recreate synthesizer
        self.synthesizer.stopSpeaking(at: .immediate)
        self.synthesizer.delegate = nil
        self.synthesizer = AVSpeechSynthesizer()
        self.synthesizer.delegate = self
        // EchoLogger.debug("AUDIO ENGINE: Recreated synthesizer to force stop", category: .voice)

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
            // EchoLogger.debug("AUDIO ENGINE: Prevented duplicate callback at [\(Date().timeIntervalSince1970)]", category: .voice)
            return
        }
        callbackCalled = true
        callback?()
    }
    
    func speak(text: String, voiceOptions: Voice, pan: Float, scenePhase: ScenePhase, isFast: Bool = false, cb: (() -> Void)?) {
        // EchoLogger.debug("AUDIO ENGINE SPEAK START: [\(Date().timeIntervalSince1970)] '\(text)' voice: \(voiceOptions.voiceName)", category: .voice)

        callback = cb
        callbackCalled = false // Reset callback flag for new speech
        currentUtteranceText = text // Track current utterance

        guard scenePhase == .active else {
            // EchoLogger.debug("AUDIO ENGINE: Not speaking as app is in the background or inactive", category: .voice)
            safeCallback()
            return
        }

        // Try SSML first, fallback to plain text for iOS 26 compatibility
        let utterance: AVSpeechUtterance
        let ssmlRepresentation = "<speak>\(escapeXMLPreservingSSML(text))</speak>"

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

        // Set speech parameters directly on utterance
        utterance.rate = Float((isFast ? 75 : voiceOptions.rate) * 1.5 / 100 + 0.5)
        utterance.volume = Float(voiceOptions.volume) / 100

        // iOS 26 Beta Fix: NEVER use synthesizer.write() - it causes crashes on iOS 26
        // For panning, we'll use a different approach that doesn't involve write()
        if pan != 0.0 {
            //EchoLogger.debug("AUDIO ENGINE: Using pan approach for '\(text)'", category: .voice)
            useSimpleSpeechWithAudioSessionPan(utterance: utterance, pan: pan)
        } else {
            // EchoLogger.debug("AUDIO ENGINE: Calling synthesizer.speak() for '\(text)'", category: .voice)
            synthesizer.speak(utterance)
        }
    }

    private func useSimpleSpeechWithAudioSessionPan(utterance: AVSpeechUtterance, pan: Float) {
        // iOS Version Detection: Check if we can safely use synthesizer.write()
        if #available(iOS 19.0, *) {
            // iOS 19+ (including iOS 26 Beta): synthesizer.write() crashes, use hardware splitter
            EchoLogger.debug("iOS 19+ detected: Channel splitting requires hardware audio splitter cable", category: .voice)
            configureAudioSessionForPanning(pan: pan)
            synthesizer.speak(utterance)
            return
        }

        // iOS 18.5 and earlier: Use real channel splitting with AVAudioPlayer
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).caf")

        // Write speech to temporary file for channel manipulation
        synthesizer.write(utterance) { [weak self] buffer in
            guard let self = self else { return }

            if let pcmBuffer = buffer as? AVAudioPCMBuffer {
                if pcmBuffer.frameLength == 0 {
                    // End of synthesis - now play the file with proper channel routing
                    DispatchQueue.main.async {
                        self.playFileWithChannelRouting(url: tempURL, pan: pan)
                    }
                    return
                }

                // Write buffer to file
                if self.audioFile == nil {
                    do {
                        self.audioFile = try AVAudioFile(
                            forWriting: tempURL,
                            settings: pcmBuffer.format.settings,
                            commonFormat: pcmBuffer.format.commonFormat,
                            interleaved: pcmBuffer.format.isInterleaved
                        )
                    } catch {
                        EchoLogger.error("Failed to create audio file: \(error)", category: .voice)
                        DispatchQueue.main.async {
                            self.safeCallback()
                        }
                        return
                    }
                }

                do {
                    try self.audioFile?.write(from: pcmBuffer)
                } catch {
                    EchoLogger.error("Failed to write to audio file: \(error)", category: .voice)
                }
            }
        }
    }

    private func playFileWithChannelRouting(url: URL, pan: Float) {
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            guard let player = self.player else {
                EchoLogger.error("Failed to create AVAudioPlayer", category: .voice)
                safeCallback()
                return
            }

            // Apply true channel routing for AirPods/headphones
            player.pan = pan  // -1.0 = full left, 1.0 = full right
            player.delegate = self
            player.prepareToPlay()
            player.play()

            EchoLogger.debug("Playing audio with channel routing: pan=\(pan)", category: .voice)
        } catch {
            EchoLogger.error("Failed to play audio file: \(error)", category: .voice)
            safeCallback()
        }
    }

    private func configureAudioSessionForPanning(pan: Float) {
        // iOS 26 Beta Fix: Don't try to reconfigure audio session - it causes warnings
        // and iOS doesn't support direct channel routing through AVAudioSession anyway

        if pan < 0 {
            EchoLogger.debug("LEFT channel requested - use hardware audio splitter cable", category: .voice)
        } else if pan > 0 {
            EchoLogger.debug("RIGHT channel requested - use hardware audio splitter cable", category: .voice)
        }

        //EchoLogger.info("Audio channel splitting requires physical audio splitter cable", category: .voice)
        //EchoLogger.info("iOS 26 Beta limitation prevents software-based channel routing", category: .voice)
    }
    


    // MARK: - AVSpeechSynthesizerDelegate

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        //EchoLogger.debug("AUDIO ENGINE FINISH: [\(Date().timeIntervalSince1970)] '\(utterance.speechString)'", category: .voice)

        // iOS Bug Fix: Only process completion if this matches our current utterance
        guard utterance.speechString == currentUtteranceText else {
            // EchoLogger.debug("AUDIO ENGINE: Ignoring completion for old utterance: '\(utterance.speechString)'", category: .voice)
            return
        }

        safeCallback()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        let timestamp = Date().timeIntervalSince1970
        EchoLogger.debug("AUDIO ENGINE CANCEL: [\(timestamp)] '\(utterance.speechString)'", category: .voice)

        // iOS Bug Fix: Only process cancellation if this matches our current utterance
        guard utterance.speechString == currentUtteranceText else {
            // EchoLogger.debug("AUDIO ENGINE: Ignoring cancellation for old utterance: '\(utterance.speechString)'", category: .voice)
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
                EchoLogger.debug("Voice created and cached successfully", category: .voice)
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

        EchoLogger.critical("No fallback voice could be created", category: .voice)
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

    private func escapeXMLPreservingSSML(_ text: String) -> String {
        // If the text doesn't contain SSML tags, use regular XML escaping
        if !text.contains("<") || !text.contains(">") {
            return escapeXML(text)
        }

        // Parse and preserve SSML tags while escaping content
        var result = ""
        var currentIndex = text.startIndex

        while currentIndex < text.endIndex {
            // Look for the next SSML tag
            if let tagStart = text.range(of: "<", range: currentIndex..<text.endIndex)?.lowerBound {
                // Escape content before the tag
                let beforeTag = String(text[currentIndex..<tagStart])
                result += escapeXML(beforeTag)

                // Find the end of the tag
                if let tagEnd = text.range(of: ">", range: tagStart..<text.endIndex)?.upperBound {
                    let tag = String(text[tagStart..<tagEnd])

                    // Check if this is a valid SSML tag we want to preserve
                    if isValidSSMLTag(tag) {
                        result += tag
                        currentIndex = tagEnd
                    } else {
                        // Not a valid SSML tag, escape it
                        result += escapeXML(tag)
                        currentIndex = tagEnd
                    }
                } else {
                    // No closing >, escape the remaining text
                    let remaining = String(text[tagStart..<text.endIndex])
                    result += escapeXML(remaining)
                    break
                }
            } else {
                // No more tags, escape the remaining text
                let remaining = String(text[currentIndex..<text.endIndex])
                result += escapeXML(remaining)
                break
            }
        }

        return result
    }

    private func isValidSSMLTag(_ tag: String) -> Bool {
        // List of SSML tags we want to preserve
        let validSSMLTags = [
            "say-as",
            "break",
            "emphasis",
            "prosody",
            "phoneme",
            "sub",
            "voice",
            "audio",
            "mark"
        ]

        // Check if the tag starts with any valid SSML tag
        for validTag in validSSMLTags {
            if tag.hasPrefix("<\(validTag)") || tag.hasPrefix("</\(validTag)") {
                return true
            }
        }

        return false
    }
}
