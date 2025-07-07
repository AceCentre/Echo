//
//  FacialGestureSwitch.swift
//  Echo
//
//  Created by Will Wade on 04/07/2025.
//

import Foundation
import SwiftData

@Model
class FacialGestureSwitch {
    var name: String
    var gestureRaw: String
    var threshold: Float
    var tapAction: SwitchAction
    var holdAction: SwitchAction
    var isEnabled: Bool
    var holdDuration: Double // Duration in seconds to trigger hold action
    var durationTypeRaw: String // Duration type for the gesture
    
    /*
     We store the FacialGesture as a string since SwiftData doesn't support enums directly
     This computed property provides convenient access to the enum
     */
    @Transient var gesture: FacialGesture? {
        get {
            return FacialGesture(rawValue: gestureRaw)
        }
        set {
            gestureRaw = newValue?.rawValue ?? ""
        }
    }

    /// Computed property for display name based on gesture
    var displayName: String {
        guard let gesture = gesture else { return name }
        return gesture.displayName
    }
    
    init(
        name: String,
        gesture: FacialGesture,
        threshold: Float? = nil,
        tapAction: SwitchAction = .none,
        holdAction: SwitchAction = .none,
        isEnabled: Bool = true,
        holdDuration: Double = 1.0
    ) {
        self.name = name
        self.gestureRaw = gesture.rawValue
        self.durationTypeRaw = "tap" // Keep for compatibility but not used
        self.threshold = threshold ?? gesture.defaultThreshold
        self.tapAction = tapAction
        self.holdAction = holdAction
        self.isEnabled = isEnabled
        self.holdDuration = holdDuration
    }
}

// MARK: - Default Facial Gesture Switches
extension FacialGestureSwitch {

}
