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
    
    var highlightColor: String
    var isHighlightTextBold: Bool
    var highlightOpacity: Double

    var entriesColor: String
    var entriesOpacity: Double
    
    var currentVocab: Vocabulary?
    var vocabHistory: Int
    var showBackInList: Bool
    var backButtonPosition: Int
    
    var cueVoice: Voice?
    var speakingVoice: Voice?
    
    var splitAudio: Bool
    var cueDirection: AudioDirection
    var speakDirection: AudioDirection
    
    var scanning: Bool
    var scanWaitTime: Double
    var scanLoops: Int
    var scanOnAppLaunch: Bool
    var scanAfterSelection: Bool
    
    var letterPrediction: Bool
    var wordPrediction: Bool
    var wordPredictionLimit: Int
    var predictionLanguage: PredictionLanguage
    var characterOrderId: String
    var wordAndLetterPrompt: Bool
    var appleWordPrediction: Bool
    var controlCommandPosition: ControlCommandDisplayOptions
    
    var messageBarBackgroundColorName: String
    var messageBarTextColorName: String
    var messageBarBackgroundOpacity: Double
    var messageBarTextOpacity: Double
    var messageBarFontSize: Int
    var isMessageBarTextBold: Bool
    
    var showOnScreenArrows: Bool
    
    var allowSwipeGestures: Bool
    
    var enableSwitchControl: Bool
    var selectedTheme: String

    var arrowSize: CGFloat
    var arrowBorderOpacity: Double
    
    init(showOnboarding: Bool = true) {
        self.showOnboarding = showOnboarding
        
        self.highlightColor = "Black"
        self.isHighlightTextBold = false
        self.highlightOpacity = 1.0
        
        self.entriesColor = "System Default"
        self.entriesOpacity = 0.5
        
        self.vocabHistory = 2
        self.currentVocab = nil
        self.showBackInList = true
        self.backButtonPosition = BackButtonPosition.bottom.rawValue
        
        self.cueVoice = nil
        self.speakingVoice = nil
        
        self.splitAudio = false
        self.cueDirection = .left
        self.speakDirection = .right
        
        self.scanning = true
        self.scanWaitTime = 2.0
        self.scanLoops = 3
        self.scanOnAppLaunch = true
        self.scanAfterSelection = true
        
        self.letterPrediction = true
        self.wordPrediction = true
        self.wordPredictionLimit = 3
        self.predictionLanguage = .english
        self.characterOrderId = CharacterOrder.defaultOrder.id
        self.wordAndLetterPrompt = true
        self.appleWordPrediction = true
        self.controlCommandPosition = .top
        
        self.messageBarBackgroundColorName = "Light Gray"
        self.messageBarTextColorName = "Black"
        self.messageBarBackgroundOpacity = 1.0
        self.messageBarTextOpacity = 1.0
        self.messageBarFontSize = 16
        self.isMessageBarTextBold = false
        
        self.showOnScreenArrows = true
        
        self.allowSwipeGestures = true
        
        self.enableSwitchControl = true
        
        self.selectedTheme = Theme.themes.first?.name ?? "System Default"
        
        self.arrowSize = 100.0
        self.arrowBorderOpacity = 1.0
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
        self.entriesColor = themeVariant.entriesColor
        self.entriesOpacity = themeVariant.entriesOpacity
        self.messageBarBackgroundColorName = themeVariant.messageBarBackgroundColorName
        self.messageBarTextColorName = themeVariant.messageBarTextColorName
        self.messageBarTextOpacity = themeVariant.messageBarTextOpacity
        self.messageBarBackgroundOpacity = themeVariant.messageBarBackgroundOpacity
        self.messageBarFontSize = themeVariant.messageBarFontSize
    }
}

