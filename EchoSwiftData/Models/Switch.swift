//
//  Switch.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 31/05/2024.
//

import Foundation
import SwiftData
import UIKit

@Model
class Switch {
    var name: String
    var keyRaw: Int?
    
    /*
     We dont store the UIKeyboardHIDUsage directly as its not compatible with swiftdata
     Instead we cast it to an Int and store that. This then just wraps the raw value for
     convience
     */
    @Transient var key: UIKeyboardHIDUsage? {
        get {
            if let unrwappedKeyRaw = keyRaw {
                return UIKeyboardHIDUsage(rawValue: unrwappedKeyRaw)
            } else {
                return nil
            }
        }
        set {
            keyRaw = newValue?.rawValue
        }
    }
    
    var tapAction: SwitchAction
    var holdAction: SwitchAction
    
    init(name: String, key: UIKeyboardHIDUsage, tapAction: SwitchAction = .none, holdAction: SwitchAction = .none) {
        self.name = name
        self.keyRaw = key.rawValue
        self.tapAction = tapAction
        self.holdAction = holdAction
    }
}
