//
//  FacialGesture.swift
//  Echo
//
//  Created by Augment Agent on 04/07/2025.
//

import Foundation
import ARKit

enum FacialGesture: String, CaseIterable, Identifiable, Codable {
    case eyeBlinkLeft = "eyeBlinkLeft"
    case eyeBlinkRight = "eyeBlinkRight"
    case eyeBlinkBoth = "eyeBlinkBoth"
    case browDownLeft = "browDownLeft"
    case browDownRight = "browDownRight"
    case browInnerUp = "browInnerUp"
    case browOuterUpLeft = "browOuterUpLeft"
    case browOuterUpRight = "browOuterUpRight"
    case cheekPuff = "cheekPuff"
    case cheekSquintLeft = "cheekSquintLeft"
    case cheekSquintRight = "cheekSquintRight"
    case jawForward = "jawForward"
    case jawLeft = "jawLeft"
    case jawRight = "jawRight"
    case jawOpen = "jawOpen"
    case mouthClose = "mouthClose"
    case mouthFunnel = "mouthFunnel"
    case mouthPucker = "mouthPucker"
    case mouthLeft = "mouthLeft"
    case mouthRight = "mouthRight"
    case mouthSmileLeft = "mouthSmileLeft"
    case mouthSmileRight = "mouthSmileRight"
    case mouthFrownLeft = "mouthFrownLeft"
    case mouthFrownRight = "mouthFrownRight"
    case mouthDimpleLeft = "mouthDimpleLeft"
    case mouthDimpleRight = "mouthDimpleRight"
    case mouthStretchLeft = "mouthStretchLeft"
    case mouthStretchRight = "mouthStretchRight"
    case mouthRollLower = "mouthRollLower"
    case mouthRollUpper = "mouthRollUpper"
    case mouthShrugLower = "mouthShrugLower"
    case mouthShrugUpper = "mouthShrugUpper"
    case mouthPressLeft = "mouthPressLeft"
    case mouthPressRight = "mouthPressRight"
    case mouthLowerDownLeft = "mouthLowerDownLeft"
    case mouthLowerDownRight = "mouthLowerDownRight"
    case mouthUpperUpLeft = "mouthUpperUpLeft"
    case mouthUpperUpRight = "mouthUpperUpRight"
    case noseSneerLeft = "noseSneerLeft"
    case noseSneerRight = "noseSneerRight"
    case tongueOut = "tongueOut"
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .eyeBlinkLeft: return String(
            localized: "Left Eye Blink",
            comment: "Display name for left eye blink gesture"
        )
        case .eyeBlinkRight: return String(
            localized: "Right Eye Blink",
            comment: "Display name for right eye blink gesture"
        )
        case .eyeBlinkBoth: return String(
            localized: "Both Eyes Blink",
            comment: "Display name for both eyes blink gesture"
        )
        case .browDownLeft: return String(
            localized: "Left Brow Down",
            comment: "Display name for left brow down gesture"
        )
        case .browDownRight: return String(
            localized: "Right Brow Down",
            comment: "Display name for right brow down gesture"
        )
        case .browInnerUp: return String(
            localized: "Inner Brow Up",
            comment: "Display name for inner brow up gesture"
        )
        case .browOuterUpLeft: return String(
            localized: "Left Outer Brow Up",
            comment: "Display name for left outer brow up gesture"
        )
        case .browOuterUpRight: return String(
            localized: "Right Outer Brow Up",
            comment: "Display name for right outer brow up gesture"
        )
        case .cheekPuff: return String(
            localized: "Cheek Puff",
            comment: "Display name for cheek puff gesture"
        )
        case .cheekSquintLeft: return String(
            localized: "Left Cheek Squint",
            comment: "Display name for left cheek squint gesture"
        )
        case .cheekSquintRight: return String(
            localized: "Right Cheek Squint",
            comment: "Display name for right cheek squint gesture"
        )
        case .jawForward: return String(
            localized: "Jaw Forward",
            comment: "Display name for jaw forward gesture"
        )
        case .jawLeft: return String(
            localized: "Jaw Left",
            comment: "Display name for jaw left gesture"
        )
        case .jawRight: return String(
            localized: "Jaw Right",
            comment: "Display name for jaw right gesture"
        )
        case .jawOpen: return String(
            localized: "Jaw Open",
            comment: "Display name for jaw open gesture"
        )
        case .mouthClose: return String(
            localized: "Mouth Close",
            comment: "Display name for mouth close gesture"
        )
        case .mouthFunnel: return String(
            localized: "Mouth Funnel",
            comment: "Display name for mouth funnel gesture"
        )
        case .mouthPucker: return String(
            localized: "Mouth Pucker",
            comment: "Display name for mouth pucker gesture"
        )
        case .mouthLeft: return String(
            localized: "Mouth Left",
            comment: "Display name for mouth left gesture"
        )
        case .mouthRight: return String(
            localized: "Mouth Right",
            comment: "Display name for mouth right gesture"
        )
        case .mouthSmileLeft: return String(
            localized: "Left Smile",
            comment: "Display name for left smile gesture"
        )
        case .mouthSmileRight: return String(
            localized: "Right Smile",
            comment: "Display name for right smile gesture"
        )
        case .mouthFrownLeft: return String(
            localized: "Left Frown",
            comment: "Display name for left frown gesture"
        )
        case .mouthFrownRight: return String(
            localized: "Right Frown",
            comment: "Display name for right frown gesture"
        )
        case .mouthDimpleLeft: return String(
            localized: "Left Dimple",
            comment: "Display name for left dimple gesture"
        )
        case .mouthDimpleRight: return String(
            localized: "Right Dimple",
            comment: "Display name for right dimple gesture"
        )
        case .mouthStretchLeft: return String(
            localized: "Left Mouth Stretch",
            comment: "Display name for left mouth stretch gesture"
        )
        case .mouthStretchRight: return String(
            localized: "Right Mouth Stretch",
            comment: "Display name for right mouth stretch gesture"
        )
        case .mouthRollLower: return String(
            localized: "Lower Lip Roll",
            comment: "Display name for lower lip roll gesture"
        )
        case .mouthRollUpper: return String(
            localized: "Upper Lip Roll",
            comment: "Display name for upper lip roll gesture"
        )
        case .mouthShrugLower: return String(
            localized: "Lower Lip Shrug",
            comment: "Display name for lower lip shrug gesture"
        )
        case .mouthShrugUpper: return String(
            localized: "Upper Lip Shrug",
            comment: "Display name for upper lip shrug gesture"
        )
        case .mouthPressLeft: return String(
            localized: "Left Lip Press",
            comment: "Display name for left lip press gesture"
        )
        case .mouthPressRight: return String(
            localized: "Right Lip Press",
            comment: "Display name for right lip press gesture"
        )
        case .mouthLowerDownLeft: return String(
            localized: "Left Lower Lip Down",
            comment: "Display name for left lower lip down gesture"
        )
        case .mouthLowerDownRight: return String(
            localized: "Right Lower Lip Down",
            comment: "Display name for right lower lip down gesture"
        )
        case .mouthUpperUpLeft: return String(
            localized: "Left Upper Lip Up",
            comment: "Display name for left upper lip up gesture"
        )
        case .mouthUpperUpRight: return String(
            localized: "Right Upper Lip Up",
            comment: "Display name for right upper lip up gesture"
        )
        case .noseSneerLeft: return String(
            localized: "Left Nose Sneer",
            comment: "Display name for left nose sneer gesture"
        )
        case .noseSneerRight: return String(
            localized: "Right Nose Sneer",
            comment: "Display name for right nose sneer gesture"
        )
        case .tongueOut: return String(
            localized: "Tongue Out",
            comment: "Display name for tongue out gesture"
        )
        }
    }
    
    var description: String {
        switch self {
        case .eyeBlinkLeft: return String(
            localized: "Blink your left eye",
            comment: "Description for left eye blink gesture"
        )
        case .eyeBlinkRight: return String(
            localized: "Blink your right eye",
            comment: "Description for right eye blink gesture"
        )
        case .eyeBlinkBoth: return String(
            localized: "Blink both eyes",
            comment: "Description for both eyes blink gesture"
        )
        case .browDownLeft: return String(
            localized: "Lower your left eyebrow",
            comment: "Description for left brow down gesture"
        )
        case .browDownRight: return String(
            localized: "Lower your right eyebrow",
            comment: "Description for right brow down gesture"
        )
        case .browInnerUp: return String(
            localized: "Raise your inner eyebrows",
            comment: "Description for inner brow up gesture"
        )
        case .browOuterUpLeft: return String(
            localized: "Raise your left outer eyebrow",
            comment: "Description for left outer brow up gesture"
        )
        case .browOuterUpRight: return String(
            localized: "Raise your right outer eyebrow",
            comment: "Description for right outer brow up gesture"
        )
        case .cheekPuff: return String(
            localized: "Puff out your cheeks",
            comment: "Description for cheek puff gesture"
        )
        case .cheekSquintLeft: return String(
            localized: "Squint your left cheek",
            comment: "Description for left cheek squint gesture"
        )
        case .cheekSquintRight: return String(
            localized: "Squint your right cheek",
            comment: "Description for right cheek squint gesture"
        )
        case .jawForward: return String(
            localized: "Push your jaw forward",
            comment: "Description for jaw forward gesture"
        )
        case .jawLeft: return String(
            localized: "Move your jaw to the left",
            comment: "Description for jaw left gesture"
        )
        case .jawRight: return String(
            localized: "Move your jaw to the right",
            comment: "Description for jaw right gesture"
        )
        case .jawOpen: return String(
            localized: "Open your mouth",
            comment: "Description for jaw open gesture"
        )
        case .mouthClose: return String(
            localized: "Close your mouth tightly",
            comment: "Description for mouth close gesture"
        )
        case .mouthFunnel: return String(
            localized: "Make an 'O' shape with your mouth",
            comment: "Description for mouth funnel gesture"
        )
        case .mouthPucker: return String(
            localized: "Pucker your lips",
            comment: "Description for mouth pucker gesture"
        )
        case .mouthLeft: return String(
            localized: "Move your mouth to the left",
            comment: "Description for mouth left gesture"
        )
        case .mouthRight: return String(
            localized: "Move your mouth to the right",
            comment: "Description for mouth right gesture"
        )
        case .mouthSmileLeft: return String(
            localized: "Smile with the left side of your mouth",
            comment: "Description for left smile gesture"
        )
        case .mouthSmileRight: return String(
            localized: "Smile with the right side of your mouth",
            comment: "Description for right smile gesture"
        )
        case .mouthFrownLeft: return String(
            localized: "Frown with the left side of your mouth",
            comment: "Description for left frown gesture"
        )
        case .mouthFrownRight: return String(
            localized: "Frown with the right side of your mouth",
            comment: "Description for right frown gesture"
        )
        case .mouthDimpleLeft: return String(
            localized: "Create a left dimple",
            comment: "Description for left dimple gesture"
        )
        case .mouthDimpleRight: return String(
            localized: "Create a right dimple",
            comment: "Description for right dimple gesture"
        )
        case .mouthStretchLeft: return String(
            localized: "Stretch the left side of your mouth",
            comment: "Description for left mouth stretch gesture"
        )
        case .mouthStretchRight: return String(
            localized: "Stretch the right side of your mouth",
            comment: "Description for right mouth stretch gesture"
        )
        case .mouthRollLower: return String(
            localized: "Roll your lower lip inward",
            comment: "Description for lower lip roll gesture"
        )
        case .mouthRollUpper: return String(
            localized: "Roll your upper lip inward",
            comment: "Description for upper lip roll gesture"
        )
        case .mouthShrugLower: return String(
            localized: "Shrug your lower lip",
            comment: "Description for lower lip shrug gesture"
        )
        case .mouthShrugUpper: return String(
            localized: "Shrug your upper lip",
            comment: "Description for upper lip shrug gesture"
        )
        case .mouthPressLeft: return String(
            localized: "Press the left side of your lips together",
            comment: "Description for left lip press gesture"
        )
        case .mouthPressRight: return String(
            localized: "Press the right side of your lips together",
            comment: "Description for right lip press gesture"
        )
        case .mouthLowerDownLeft: return String(
            localized: "Pull down the left side of your lower lip",
            comment: "Description for left lower lip down gesture"
        )
        case .mouthLowerDownRight: return String(
            localized: "Pull down the right side of your lower lip",
            comment: "Description for right lower lip down gesture"
        )
        case .mouthUpperUpLeft: return String(
            localized: "Lift the left side of your upper lip",
            comment: "Description for left upper lip up gesture"
        )
        case .mouthUpperUpRight: return String(
            localized: "Lift the right side of your upper lip",
            comment: "Description for right upper lip up gesture"
        )
        case .noseSneerLeft: return String(
            localized: "Sneer with the left side of your nose",
            comment: "Description for left nose sneer gesture"
        )
        case .noseSneerRight: return String(
            localized: "Sneer with the right side of your nose",
            comment: "Description for right nose sneer gesture"
        )
        case .tongueOut: return String(
            localized: "Stick out your tongue",
            comment: "Description for tongue out gesture"
        )
        }
    }
    
    /// Maps FacialGesture to ARKit's BlendShapeLocation
    var blendShapeLocation: ARFaceAnchor.BlendShapeLocation {
        switch self {
        case .eyeBlinkLeft: return .eyeBlinkLeft
        case .eyeBlinkRight: return .eyeBlinkRight
        case .eyeBlinkBoth: return .eyeBlinkLeft // Special case - will be handled in detection logic
        case .browDownLeft: return .browDownLeft
        case .browDownRight: return .browDownRight
        case .browInnerUp: return .browInnerUp
        case .browOuterUpLeft: return .browOuterUpLeft
        case .browOuterUpRight: return .browOuterUpRight
        case .cheekPuff: return .cheekPuff
        case .cheekSquintLeft: return .cheekSquintLeft
        case .cheekSquintRight: return .cheekSquintRight
        case .jawForward: return .jawForward
        case .jawLeft: return .jawLeft
        case .jawRight: return .jawRight
        case .jawOpen: return .jawOpen
        case .mouthClose: return .mouthClose
        case .mouthFunnel: return .mouthFunnel
        case .mouthPucker: return .mouthPucker
        case .mouthLeft: return .mouthLeft
        case .mouthRight: return .mouthRight
        case .mouthSmileLeft: return .mouthSmileLeft
        case .mouthSmileRight: return .mouthSmileRight
        case .mouthFrownLeft: return .mouthFrownLeft
        case .mouthFrownRight: return .mouthFrownRight
        case .mouthDimpleLeft: return .mouthDimpleLeft
        case .mouthDimpleRight: return .mouthDimpleRight
        case .mouthStretchLeft: return .mouthStretchLeft
        case .mouthStretchRight: return .mouthStretchRight
        case .mouthRollLower: return .mouthRollLower
        case .mouthRollUpper: return .mouthRollUpper
        case .mouthShrugLower: return .mouthShrugLower
        case .mouthShrugUpper: return .mouthShrugUpper
        case .mouthPressLeft: return .mouthPressLeft
        case .mouthPressRight: return .mouthPressRight
        case .mouthLowerDownLeft: return .mouthLowerDownLeft
        case .mouthLowerDownRight: return .mouthLowerDownRight
        case .mouthUpperUpLeft: return .mouthUpperUpLeft
        case .mouthUpperUpRight: return .mouthUpperUpRight
        case .noseSneerLeft: return .noseSneerLeft
        case .noseSneerRight: return .noseSneerRight
        case .tongueOut: return .tongueOut
        }
    }
    
    /// Default threshold for gesture detection
    var defaultThreshold: Float {
        switch self {
        case .eyeBlinkLeft, .eyeBlinkRight, .eyeBlinkBoth:
            return 0.8 // Higher threshold for blinks
        case .jawOpen:
            return 0.3 // Lower threshold for mouth opening
        case .mouthSmileLeft, .mouthSmileRight:
            return 0.5 // Medium threshold for smiles
        default:
            return 0.6 // Default threshold for most gestures
        }
    }
    
    /// Commonly used gestures for switch input
    static var commonGestures: [FacialGesture] {
        return [
            .eyeBlinkLeft,
            .eyeBlinkRight,
            .eyeBlinkBoth,
            .jawOpen,
            .mouthSmileLeft,
            .mouthSmileRight,
            .browInnerUp,
            .cheekPuff,
            .mouthPucker
        ]
    }
}
