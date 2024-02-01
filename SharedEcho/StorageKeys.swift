//
//  File.swift
//  Echo
//
//  Created by Gavin Henderson on 31/10/2023.
//

import Foundation

public struct StorageKeys {
    public static var showOnboarding = "showOnboarding"
    public static var arrowLocationX = "arrowLocationX"
    public static var arrowLocationY = "arrowLocationY"
    public static var allowAnalytics = "allowAnalytics"
    public static var scanning = "scanning"
    public static var scanWaitTime = "scanWaitTime"
    public static var scanLoops = "scanLoops"
    public static var scanOnLaunch = "scanOnLaunch"
    public static var scanAfterSelection = "scanAfterSelection"
    public static var showOnScreenArrows = "showOnScreenArrows"
    public static var enableSwitchControl = "enableSwitchControl"
    public static var allowSwipeGestures = "allowSwipeGestures"
    public static var letterPrediction = "letterPrediction"
    public static var wordPrediction = "wordPrediction"
    public static var wordPredictionLimit = "wordPredictionLimit"
    public static var predictionLanguage = "predictionLanguage"
    public static var characterOrder = "characterOrder"
    public static var wordAndLetterPrompt = "wordAndLetterPrompt"
    public static var numberOfOpens = "numberOfOpens"
    public static var numberOfRatingPromptsShown = "numberOfRatingPromptsShown"
    public static var appleWordPrediction = "appleWordPrediction"
    
    public static var switchesList = "switchesListV2"
    public static var speakingVoiceOptions = "speakingVoiceOptions"
    public static var cueVoiceOptions = "cueVoiceOptions"
    
    public static var controlCommandPosition = "controlCommandPosition"
    
    public static var allowedViaTest = [
        showOnboarding,
        scanning,
        allowAnalytics,
        letterPrediction,
        wordPrediction
    ]
}
