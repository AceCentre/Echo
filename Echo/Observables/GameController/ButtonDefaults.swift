//
//  ButtonDefaults.swift
//  Echo
//
//  Created by Gavin Henderson on 18/12/2023.
//

import Foundation

/**
 This stores the default actions of controller buttons
 Its worth noting that this will only work in english, in the future it should be extended to work in all languages
**/
enum ButtonDefaults: String {
    // Switch Buttons + General
    case a = "A Button"
    case b = "B Button"
    case up = "Up Button"
    case down = "Down Button"
    case left = "Left Button"
    case right = "Right Button"
    case share = "Share Button"
    case home = "HOME Button"
    case lBumper = "L Button"
    case minus = "- Button"
    case plus = "+ Button"
    case rBumper = "R Button"
    case x = "X Button"
    case y = "Y Button"
    case zl = "ZL Button"
    case zr = "ZR Button"
    case leftStick = "Left Stick"
    case rightStick = "Right Stick"
    
    // Playstation Buttons
    case circle = "Circle Button"
    case l1Button = "L1 Button"
    case l2Button = "L2 Button"
    case psButton = "PS Button"
    case options = "OPTIONS Button"
    case r1 = "R1 Button"
    case r2 = "R2 Button"
    case sharePs = "SHARE Button"
    case square = "Square Button"
    case triangle = "Triangle Button"
    case cross = "Cross Button"
    
    var tapAction: Action {
        switch self {
        case .a:
            return .select
        case .b:
            return .nextNode
        case .up:
            return .prevNode
        case .down:
            return .nextNode
        case .left:
            return .back
        case .right:
            return .select
        case .share:
            return .none
        case .home:
            return .none
        case .lBumper:
            return .prevNode
        case .minus:
            return .prevNode
        case .plus:
            return .select
        case .rBumper:
            return .select
        case .x:
            return .prevNode
        case .y:
            return .back
        case .zl:
            return .back
        case .zr:
            return .select
        case .leftStick:
            return .select
        case .rightStick:
            return .select
        case .circle:
            return .select
        case .l1Button:
            return .none
        case .l2Button:
            return .none
        case .psButton:
            return .none
        case .options:
            return .none
        case .r1:
            return .none
        case .r2:
            return .none
        case .sharePs:
            return .none
        case .square:
            return .back
        case .triangle:
            return .prevNode
        case .cross:
            return .nextNode
        }
    }
    
    var holdAction: Action {
        switch self {
        case .a:
            return .none
        case .b:
            return .fast
        case .up:
            return .none
        case .down:
            return .fast
        case .left:
            return .none
        case .right:
            return .none
        case .share:
            return .none
        case .home:
            return .none
        case .lBumper:
            return .none
        case .minus:
            return .none
        case .plus:
            return .none
        case .rBumper:
            return .none
        case .x:
            return .none
        case .y:
            return .none
        case .zl:
            return .none
        case .zr:
            return .none
        case .leftStick:
            return .none
        case .rightStick:
            return .none
        case .circle:
            return .none
        case .l1Button:
            return .none
        case .l2Button:
            return .none
        case .psButton:
            return .none
        case .options:
            return .none
        case .r1:
            return .none
        case .r2:
            return .none
        case .sharePs:
            return .none
        case .square:
            return .none
        case .triangle:
            return .none
        case .cross:
            return .fast
        }
    }
}
