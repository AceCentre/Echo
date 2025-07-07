//
//  GestureDurationType.swift
//  Echo
//
//  Created by Augment Agent on 04/07/2025.
//

import Foundation

enum GestureDurationType: String, CaseIterable, Identifiable, Codable {
    case tap = "tap"
    case shortHold = "shortHold"
    case longHold = "longHold"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .tap:
            return String(localized: "Tap", comment: "Display name for tap gesture duration")
        case .shortHold:
            return String(localized: "Short Hold", comment: "Display name for short hold gesture duration")
        case .longHold:
            return String(localized: "Long Hold", comment: "Display name for long hold gesture duration")
        }
    }
    
    var description: String {
        switch self {
        case .tap:
            return String(localized: "Quick gesture detection", comment: "Description for tap gesture duration")
        case .shortHold:
            return String(localized: "Hold gesture briefly", comment: "Description for short hold gesture duration")
        case .longHold:
            return String(localized: "Hold gesture for longer", comment: "Description for long hold gesture duration")
        }
    }
    
    /// Returns the duration in seconds based on global settings
    func duration(from settings: Settings) -> Double {
        switch self {
        case .tap:
            return 0.0 // Immediate detection
        case .shortHold:
            return settings.facialGestureShortHoldDuration
        case .longHold:
            return settings.facialGestureLongHoldDuration
        }
    }
}
