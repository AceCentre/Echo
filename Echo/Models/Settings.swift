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
    var messageBarFontSize: Int
    
    var showOnScreenArrows: Bool
    
    var allowSwipeGestures: Bool
    
    var enableSwitchControl: Bool
    
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
}
