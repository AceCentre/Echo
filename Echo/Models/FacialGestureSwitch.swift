//
//  FacialGestureSwitch.swift
//  Echo
//
//  Created by Augment Agent on 04/07/2025.
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
        self.threshold = threshold ?? gesture.defaultThreshold
        self.tapAction = tapAction
        self.holdAction = holdAction
        self.isEnabled = isEnabled
        self.holdDuration = holdDuration
    }
}

// MARK: - Default Facial Gesture Switches
extension FacialGestureSwitch {
    static func createDefaultSwitches() -> [FacialGestureSwitch] {
        return [
            FacialGestureSwitch(
                name: String(localized: "Left Eye Blink", comment: "Default facial gesture switch name"),
                gesture: .eyeBlinkLeft,
                tapAction: .nextNode,
                holdAction: .none
            ),
            FacialGestureSwitch(
                name: String(localized: "Right Eye Blink", comment: "Default facial gesture switch name"),
                gesture: .eyeBlinkRight,
                tapAction: .select,
                holdAction: .none
            ),
            FacialGestureSwitch(
                name: String(localized: "Mouth Open", comment: "Default facial gesture switch name"),
                gesture: .jawOpen,
                tapAction: .goBack,
                holdAction: .none
            )
        ]
    }
}
