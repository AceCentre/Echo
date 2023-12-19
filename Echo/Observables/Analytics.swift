//
//  Analytics.swift
//  Echo
//
//  Created by Gavin Henderson on 24/10/2023.
//

import Foundation
import PostHog
import SwiftUI
import SharedEcho

enum AnalyticKey: String, CaseIterable {
    case appLaunch
    case readCue
    case readSpeak
    case userInteraction
    case wordAdded
    case letterAdded
    case onboarding
    
    var explanation: String {
        switch self {
        case .appLaunch: return String(
            localized: "When the app is opened",
            comment: "A label for an analytics event"
        )
        case .readCue: return String(
            localized: "When something is read out in the cue voice",
            comment: "A label for an analytics event"
        )
        case .readSpeak: return String(
            localized: "When something is read out in the speaking voice",
            comment: "A label for an analytics event"
        )
        case .userInteraction: return String(
            localized: "When you press a switch, use the arrow or swipe on the screen",
            comment: "A label for an analytics event"
        )
        case .wordAdded: return String(
            localized: "When you enter a full word we log if it was predicted or not. We do not log the word",
            comment: "A label for an analytics event"
        )
        case .letterAdded: return String(
            localized: "When you enter a letter we log if it was predicted or not. We do not log the word",
            comment: "A label for an analytics event"
        )
        case .onboarding: return String(
            localized: "When you complete the initial onboarding steps.",
            comment: "A label for an analytics event"
        )
        }
    }
}

protocol Analytic {
    func getAnalyticData() -> [String: Any]
}

class Analytics: ObservableObject {
    @AppStorage(StorageKeys.allowAnalytics) var allowAnalytics = true
    
    var voiceEngine: VoiceEngine?
    var accessOptions: AccessOptions?
    var scanningOptions: ScanningOptions?
    var spellingOptions: SpellingOptions?
    
    var posthog: PHGPostHog?
    
    var anonId: String {
        if let unwrappedPosthog = posthog {
            return unwrappedPosthog.getAnonymousId()
        }
        return "UNKNOWN"
    }
    
    func setupPostHog() -> PHGPostHog? {
        let configuration = PHGPostHogConfiguration(apiKey: "phc_Iu0qJYNNfok6scjPSnKIYF1EKgWDCMpuc8vYGYMLMip", host: "https://app.posthog.com")
        
        configuration.captureApplicationLifecycleEvents = true
        configuration.recordScreenViews = false
        configuration.flushAt = 1
        
        PHGPostHog.setup(with: configuration)
        
        return PHGPostHog.shared()
    }
    
    func load(voiceEngine: VoiceEngine, accessOptions: AccessOptions, scanningOptions: ScanningOptions, spellingOptions: SpellingOptions) {
        self.voiceEngine = voiceEngine
        self.accessOptions = accessOptions
        self.scanningOptions = scanningOptions
        self.spellingOptions = spellingOptions
        
        if allowAnalytics {
            self.posthog = self.setupPostHog()
        }
    }
    
    func userInteraction(type: String, extraInfo: String) {
        event(.userInteraction, extraProperties: [
            "interactionType": type,
            "extraInfo": extraInfo
        ])
    }
    
    func gamePadButtonPress(controllerName: String, buttonName: String) {
        event(.userInteraction, extraProperties: [
            "interactionType": "GamepadButtonPress",
            "controllerName": controllerName,
            "buttonName": buttonName
        ])
    }
    
    func wordAdded(isPredicted: Bool) {
        event(.wordAdded, extraProperties: ["isPredicted": isPredicted])
    }
    
    func letterAdded(isPredicted: Bool) {
        event(.letterAdded, extraProperties: ["isPredicted": isPredicted])
    }
    
    func finishedOnboarding(pageNumber: Int, finishType: String) {
        event(.onboarding, extraProperties: ["pageNumber": pageNumber, "finishType": finishType])
    }
    
    func utteranceSpoken(numberOfWords: Int, averageWordLength: Int, totalUtteranceLength: Int) {
        event(.readSpeak, extraProperties: [
            "numberOfWords": numberOfWords,
            "averageWordLength": averageWordLength,
            "totalUtteranceLength": totalUtteranceLength
        ])
    }
    
    func event(_ key: AnalyticKey, extraProperties: [String: Any] = [:]) {
        let setProperties: [String: Any] = [:]
            .merging(voiceEngine?.getAnalyticData() ?? [:], uniquingKeysWith: { (current, _) in current })
            .merging(accessOptions?.getAnalyticData() ?? [:], uniquingKeysWith: { (current, _) in current })
            .merging(scanningOptions?.getAnalyticData() ?? [:], uniquingKeysWith: { (current, _) in current })
            .merging(spellingOptions?.getAnalyticData() ?? [:], uniquingKeysWith: { (current, _) in current })
        
        let properties = [
            "$set": setProperties
        ].merging(extraProperties, uniquingKeysWith: { (current, _) in current })

        if let unwrappedPosthog = posthog, allowAnalytics == true {
            print("ANALYTICS EVENT: ", key.rawValue, extraProperties)
            unwrappedPosthog.capture(
                key.rawValue,
                properties: properties
            )
        } else if allowAnalytics == true {
            self.posthog = self.setupPostHog()
            
            if let unwrappedPosthog = posthog {
                unwrappedPosthog.capture(
                    key.rawValue,
                    properties: properties
                )
                print("ANALYTICS EVENT (NEW): ", key.rawValue, extraProperties)
            }
        } else {
            print("ANALYTICS EVENT (SUPRESSED): ", key.rawValue, extraProperties)
        }
    }
}
