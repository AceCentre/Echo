//
//  Settings.swift
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
    
    var highlightColor: String = "black"
    var isHighlightTextBold: Bool = false
    var highlightOpacity: Double = 1.0
    
    var arrowSize: CGFloat = 172.0
    var arrowBorderOpacity: Double = 1.0 
    
    var currentVocab: Vocabulary?
    var vocabHistory: Int
    var showBackInList: Bool = true
    var backButtonPosition: Int = BackButtonPosition.bottom.rawValue
    
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
    
    var messageBarColorName: String = "black"
    var messageBarBackgroundColorName: String = "white" // Default background color
    var messageBarTextColorName: String = "black" // Default text color
    var messageBarBackgroundOpacity: Double = 1.0
    var messageBarOpacity: Double = 1.0
    var messageBarTextOpacity: Double = 1.0
    var messageBarFontSize: Int = 16
    var isMessageBarTextBold: Bool = false
    
    var showOnScreenArrows: Bool
    
    var allowSwipeGestures: Bool
    
    var enableSwitchControl: Bool
    var selectedTheme: String = "System Default"
    
    init(showOnboarding: Bool = true) {
        self.vocabHistory = 2
        
        self.showOnboarding = showOnboarding
        
        self.splitAudio = false
        self.cueDirection = .left
        self.speakDirection = .right
        
        self.scanning = true
        self.scanWaitTime = 2
        self.scanLoops = 3
        self.scanOnAppLaunch = true
        self.scanAfterSelection = true
        
        self.letterPrediction = true
        self.wordPrediction = true
        self.wordPredictionLimit = 3
        self.predictionLanguage = PredictionLanguage.english
        self.characterOrderId = CharacterOrder.defaultOrder.id
        self.wordAndLetterPrompt = true
        self.appleWordPrediction = true
        self.controlCommandPosition = .top
        self.messageBarFontSize = 25
        
        self.showOnScreenArrows = true
        
        self.allowSwipeGestures = true
        
        self.enableSwitchControl = true
        
        self.showBackInList = true
        self.backButtonPosition = BackButtonPosition.bottom.rawValue
    }
    
    func applyTheme(_ theme: Theme) {
            highlightColor = theme.highlightColor
            highlightOpacity = theme.highlightOpacity
            isHighlightTextBold = theme.isHighlightTextBold
            messageBarColorName = theme.messageBarColorName
            messageBarBackgroundColorName = theme.messageBarBackgroundColorName
            messageBarTextColorName = theme.messageBarTextColorName
            messageBarTextOpacity = theme.messageBarTextOpacity
            messageBarBackgroundOpacity = theme.messageBarBackgroundOpacity
            messageBarFontSize = theme.messageBarFontSize
            selectedTheme = theme.name
        }
}
