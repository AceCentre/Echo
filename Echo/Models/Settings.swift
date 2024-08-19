//
//  self.swift
// Echo
//
//  Created by Gavin Henderson on 24/05/2024.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Settings {
    var showOnboarding: Bool

    // Vocabulary settings
    var currentVocab: Vocabulary?
    var vocabHistory: Int
    var showBackInList: Bool
    var backButtonPosition: Int

    // Audio settings
    var cueVoice: Voice?
    var speakingVoice: Voice?
    var splitAudio: Bool
    var cueDirection: AudioDirection
    var speakDirection: AudioDirection

    // Scanning settings
    var scanning: Bool
    var scanWaitTime: Double
    var scanLoops: Int
    var scanOnAppLaunch: Bool
    var scanAfterSelection: Bool

    // Prediction settings
    var letterPrediction: Bool
    var wordPrediction: Bool
    var wordPredictionLimit: Int
    var predictionLanguage: PredictionLanguage
    var characterOrderId: String
    var wordAndLetterPrompt: Bool
    var appleWordPrediction: Bool
    var controlCommandPosition: ControlCommandDisplayOptions

    // UI settings
    var showOnScreenArrows: Bool
    var allowSwipeGestures: Bool
    var enableSwitchControl: Bool
    var selectedTheme: String
    var arrowSize: CGFloat
    var arrowBorderOpacity: Double

    // Highlight settings
    var highlightColor: String
    var highlightOpacity: Double
    var isHighlightTextBold: Bool
    var useCustomHighlightFontSize: Bool
    var highlightFontSize: Int
    var highlightFontName: String

    // Entries settings
    var entriesColor: String
    var entriesOpacity: Double
    var useCustomEntriesFontSize: Bool
    var entriesFontSize: Int
    var entriesFontName: String

    // Message Bar settings
    var isMessageBarTextBold: Bool
    var messageBarTextColor: String
    var messageBarTextOpacity: Double
    var messageBarBackgroundColor: String
    var messageBarBackgroundOpacity: Double
    var messageBarFontName: String
    var messageBarFontSize: Int

    init(showOnboarding: Bool = true) {
        self.showOnboarding = showOnboarding

        // Initialize Vocabulary settings
        self.vocabHistory = 2
        self.currentVocab = nil
        self.showBackInList = true
        self.backButtonPosition = BackButtonPosition.bottom.rawValue

        // Initialize Audio settings
        self.cueVoice = nil
        self.speakingVoice = nil
        self.splitAudio = false
        self.cueDirection = .left
        self.speakDirection = .right

        // Initialize Scanning settings
        self.scanning = true
        self.scanWaitTime = 2.0
        self.scanLoops = 3
        self.scanOnAppLaunch = true
        self.scanAfterSelection = true

        // Initialize Prediction settings
        self.letterPrediction = true
        self.wordPrediction = true
        self.wordPredictionLimit = 3
        self.predictionLanguage = .english
        self.characterOrderId = CharacterOrder.defaultOrder.id
        self.wordAndLetterPrompt = true
        self.appleWordPrediction = true
        self.controlCommandPosition = .top

        // Initialize UI settings
        self.showOnScreenArrows = true
        self.allowSwipeGestures = true
        self.enableSwitchControl = true
        self.selectedTheme = Theme.themes.first?.name ?? "System Default"
        self.arrowSize = 100.0
        self.arrowBorderOpacity = 1.0

        // Initialize Highlight settings
        self.highlightColor = "Black"
        self.isHighlightTextBold = false
        self.highlightOpacity = 1.0
        self.useCustomHighlightFontSize = false
        self.highlightFontName = "System"
        self.highlightFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize.toInt()

        // Initialize Entries settings
        self.entriesColor = "System Default"
        self.entriesOpacity = 0.5
        self.useCustomEntriesFontSize = false
        self.entriesFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize.toInt()
        self.entriesFontName = "System"

        // Initialize Message Bar settings
        self.isMessageBarTextBold = false
        self.messageBarTextColor = "Black"
        self.messageBarTextOpacity = 1.0
        self.messageBarBackgroundColor = "Light Gray"
        self.messageBarBackgroundOpacity = 1.0
        self.messageBarFontName = "System"
        self.messageBarFontSize = 16
    }

    func applyTheme(_ theme: Theme, for colorScheme: ColorScheme) {
        let themeVariant: Theme.ThemeVariant

        if colorScheme == .dark {
            themeVariant = theme.darkVariant
        } else {
            themeVariant = theme.lightVariant
        }

        // Apply the selected themeVariant to your UI
        self.highlightColor = themeVariant.highlightColor
        self.highlightOpacity = themeVariant.highlightOpacity
        self.isHighlightTextBold = themeVariant.isHighlightTextBold
        self.useCustomHighlightFontSize = themeVariant.useCustomHighlightFontSize
        self.highlightFontSize = Int(themeVariant.highlightFontSize)
        self.highlightFontName = themeVariant.highlightFontName

        self.entriesColor = themeVariant.entriesColor
        self.entriesOpacity = themeVariant.entriesOpacity
        self.useCustomEntriesFontSize = themeVariant.useCustomEntriesFontSize
        self.entriesFontSize = Int(themeVariant.entriesFontSize)
        self.entriesFontName = themeVariant.entriesFontName

        self.messageBarTextColor = themeVariant.messageBarTextColor
        self.messageBarTextOpacity = themeVariant.messageBarTextOpacity
        self.messageBarBackgroundColor = themeVariant.messageBarBackgroundColor
        self.messageBarBackgroundOpacity = themeVariant.messageBarBackgroundOpacity
        self.messageBarFontName = themeVariant.messageBarFontName
        self.messageBarFontSize = Int(themeVariant.messageBarFontSize)
    }
}

// To get system font size
extension CGFloat {
    func toInt() -> Int {
        return Int(self)
    }
}
