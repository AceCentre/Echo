//
//  FacialGesture.swift
//  Echo
//
//  Created by Will Wade on 04/07/2025.
//

import Foundation
import ARKit

enum FacialGesture: String, CaseIterable, Identifiable, Codable {
    case eyeBlinkLeft = "eyeBlinkLeft"
    case eyeBlinkRight = "eyeBlinkRight"
    case eyeBlinkEither = "eyeBlinkEither"
    case eyeOpenLeft = "eyeOpenLeft"
    case eyeOpenRight = "eyeOpenRight"
    case eyeOpenEither = "eyeOpenEither"
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

    // Gaze direction gestures
    case lookUp = "lookUp"
    case lookDown = "lookDown"
    case lookLeft = "lookLeft"
    case lookRight = "lookRight"

    // Head movement gestures
    case headNodUp = "headNodUp"
    case headNodDown = "headNodDown"
    case headShakeLeft = "headShakeLeft"
    case headShakeRight = "headShakeRight"
    case headTiltLeft = "headTiltLeft"
    case headTiltRight = "headTiltRight"
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
        case .eyeBlinkEither: return String(
            localized: "Either Eye Blink",
            comment: "Display name for either eye blink gesture"
        )
        case .eyeOpenLeft: return String(
            localized: "Left Eye Open",
            comment: "Display name for left eye open gesture"
        )
        case .eyeOpenRight: return String(
            localized: "Right Eye Open",
            comment: "Display name for right eye open gesture"
        )
        case .eyeOpenEither: return String(
            localized: "Either Eye Open",
            comment: "Display name for either eye open gesture"
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
        case .lookUp: return String(
            localized: "Look Up",
            comment: "Display name for look up gesture"
        )
        case .lookDown: return String(
            localized: "Look Down",
            comment: "Display name for look down gesture"
        )
        case .lookLeft: return String(
            localized: "Look Left",
            comment: "Display name for look left gesture"
        )
        case .lookRight: return String(
            localized: "Look Right",
            comment: "Display name for look right gesture"
        )
        case .headNodUp: return String(
            localized: "Head Nod Up",
            comment: "Display name for head nod up gesture"
        )
        case .headNodDown: return String(
            localized: "Head Nod Down",
            comment: "Display name for head nod down gesture"
        )
        case .headShakeLeft: return String(
            localized: "Head Shake Left",
            comment: "Display name for head shake left gesture"
        )
        case .headShakeRight: return String(
            localized: "Head Shake Right",
            comment: "Display name for head shake right gesture"
        )
        case .headTiltLeft: return String(
            localized: "Head Tilt Left",
            comment: "Display name for head tilt left gesture"
        )
        case .headTiltRight: return String(
            localized: "Head Tilt Right",
            comment: "Display name for head tilt right gesture"
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
        case .eyeBlinkEither: return String(
            localized: "Blink either eye",
            comment: "Description for either eye blink gesture"
        )
        case .eyeOpenLeft: return String(
            localized: "Keep your left eye open",
            comment: "Description for left eye open gesture"
        )
        case .eyeOpenRight: return String(
            localized: "Keep your right eye open",
            comment: "Description for right eye open gesture"
        )
        case .eyeOpenEither: return String(
            localized: "Keep either eye open",
            comment: "Description for either eye open gesture"
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
        case .lookUp: return String(
            localized: "Look up with your eyes",
            comment: "Description for look up gesture"
        )
        case .lookDown: return String(
            localized: "Look down with your eyes",
            comment: "Description for look down gesture"
        )
        case .lookLeft: return String(
            localized: "Look left with your eyes",
            comment: "Description for look left gesture"
        )
        case .lookRight: return String(
            localized: "Look right with your eyes",
            comment: "Description for look right gesture"
        )
        case .headNodUp: return String(
            localized: "Nod your head up",
            comment: "Description for head nod up gesture"
        )
        case .headNodDown: return String(
            localized: "Nod your head down",
            comment: "Description for head nod down gesture"
        )
        case .headShakeLeft: return String(
            localized: "Shake your head to the left",
            comment: "Description for head shake left gesture"
        )
        case .headShakeRight: return String(
            localized: "Shake your head to the right",
            comment: "Description for head shake right gesture"
        )
        case .headTiltLeft: return String(
            localized: "Tilt your head to the left",
            comment: "Description for head tilt left gesture"
        )
        case .headTiltRight: return String(
            localized: "Tilt your head to the right",
            comment: "Description for head tilt right gesture"
        )
        }
    }

    /// Gesture category for threshold UI customization
    enum GestureCategory {
        case intensity    // ARKit blend shapes (0.0-1.0 scale)
        case angular      // Head movements (radians)
        case composite    // Complex calculations (gaze direction)
    }

    /// Category of this gesture for threshold UI customization
    var category: GestureCategory {
        switch self {
        case .headNodUp, .headNodDown, .headShakeLeft, .headShakeRight, .headTiltLeft, .headTiltRight:
            return .angular
        case .lookUp, .lookDown, .lookLeft, .lookRight:
            return .composite
        default:
            return .intensity
        }
    }

    /// Context-aware threshold label based on gesture category
    var thresholdLabel: String {
        switch category {
        case .intensity:
            return String(localized: "Intensity Required", comment: "Threshold label for intensity-based gestures")
        case .angular:
            return String(localized: "Movement Amount", comment: "Threshold label for angular head movements")
        case .composite:
            return String(localized: "Sensitivity", comment: "Threshold label for composite gestures like gaze")
        }
    }

    /// Helpful description of what the threshold means for this gesture
    var thresholdDescription: String {
        switch self {
        case .eyeBlinkLeft, .eyeBlinkRight, .eyeBlinkEither:
            return String(localized: "How much you need to close your eyes", comment: "Threshold description for eye blink gestures")
        case .eyeOpenLeft, .eyeOpenRight, .eyeOpenEither:
            return String(localized: "How wide your eyes need to be open", comment: "Threshold description for eye open gestures")
        case .jawOpen:
            return String(localized: "How much you need to open your mouth", comment: "Threshold description for jaw open gesture")
        case .mouthClose:
            return String(localized: "How tightly you need to close your mouth", comment: "Threshold description for mouth close gesture")
        case .mouthSmileLeft, .mouthSmileRight:
            return String(localized: "How much you need to smile", comment: "Threshold description for smile gestures")
        case .headNodUp, .headNodDown:
            return String(localized: "How far you need to nod your head", comment: "Threshold description for head nod gestures")
        case .headShakeLeft, .headShakeRight:
            return String(localized: "How far you need to shake your head", comment: "Threshold description for head shake gestures")
        case .headTiltLeft, .headTiltRight:
            return String(localized: "How far you need to tilt your head", comment: "Threshold description for head tilt gestures")
        case .lookUp, .lookDown, .lookLeft, .lookRight:
            return String(localized: "How much you need to move your gaze", comment: "Threshold description for gaze direction gestures")
        case .browInnerUp:
            return String(localized: "How much you need to raise your eyebrows", comment: "Threshold description for eyebrow raise gesture")
        case .cheekPuff:
            return String(localized: "How much you need to puff your cheeks", comment: "Threshold description for cheek puff gesture")
        case .mouthPucker:
            return String(localized: "How much you need to pucker your lips", comment: "Threshold description for mouth pucker gesture")
        default:
            return String(localized: "How much of the gesture is required", comment: "Generic threshold description")
        }
    }

    /// Display threshold value with appropriate units
    func thresholdDisplayValue(_ threshold: Float) -> String {
        switch category {
        case .intensity:
            return String(localized: "\(Int(threshold * 100))% intensity", comment: "Threshold display for intensity gestures")
        case .angular:
            let degrees = Int(threshold * 180 / Float.pi)
            return String(localized: "\(degrees)° movement", comment: "Threshold display for angular gestures")
        case .composite:
            let level = Int(threshold * 10)
            return String(localized: "Level \(level)/10", comment: "Threshold display for composite gestures")
        }
    }

    /// Maps FacialGesture to ARKit's BlendShapeLocation
    var blendShapeLocation: ARFaceAnchor.BlendShapeLocation {
        switch self {
        case .eyeBlinkLeft: return .eyeBlinkLeft
        case .eyeBlinkRight: return .eyeBlinkRight
        case .eyeBlinkEither: return .eyeBlinkLeft // Special case - will be handled in detection logic
        case .eyeOpenLeft: return .eyeBlinkLeft // Use same blend shape as blink but inverted
        case .eyeOpenRight: return .eyeBlinkRight // Use same blend shape as blink but inverted
        case .eyeOpenEither: return .eyeBlinkLeft // Special case - will be handled in detection logic
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
        case .lookUp: return .eyeLookUpLeft // Use left eye look up as primary, will handle specially
        case .lookDown: return .eyeLookDownLeft // Use left eye look down as primary, will handle specially
        case .lookLeft: return .eyeLookOutLeft // Use left eye look out as primary, will handle specially
        case .lookRight: return .eyeLookInLeft // Use left eye look in as primary, will handle specially

        // Head movement gestures don't use blend shapes - these will be handled specially
        case .headNodUp, .headNodDown, .headShakeLeft, .headShakeRight, .headTiltLeft, .headTiltRight:
            return .eyeBlinkLeft // Placeholder - not used for head movements
        }
    }
    
    /// Whether this gesture has inverted behavior (ARKit value decreases when gesture is performed)
    var isInverted: Bool {
        switch self {
        case .mouthClose:
            // mouthClose: ARKit reports higher values when mouth is open,
            // but we want higher values when mouth is closed
            return true
        case .eyeOpenLeft, .eyeOpenRight, .eyeOpenEither:
            // eyeOpen: ARKit reports higher values when eyes are closed (blinking),
            // but we want higher values when eyes are OPEN (opposite of blink)
            return true
        // Add other inverted gestures here if discovered during testing
        // Examples might include other "close" or "press" type gestures
        default:
            return false
        }
    }

    /// Default threshold for gesture detection
    var defaultThreshold: Float {
        switch self {
        case .eyeBlinkLeft, .eyeBlinkRight, .eyeBlinkEither:
            return 0.8 // Higher threshold for blinks
        case .eyeOpenLeft, .eyeOpenRight, .eyeOpenEither:
            return 0.7 // Medium threshold for detecting open eyes
        case .jawOpen:
            return 0.3 // Lower threshold for mouth opening
        case .mouthSmileLeft, .mouthSmileRight:
            return 0.5 // Medium threshold for smiles
        case .lookUp, .lookDown, .lookLeft, .lookRight:
            return 0.4 // Medium-low threshold for gaze direction
        case .headNodUp, .headNodDown:
            return 0.15 // Threshold for head nod (radians) - reduced for better sensitivity (~8.6 degrees)
        case .headShakeLeft, .headShakeRight:
            return 0.08 // Threshold for head shake (radians) - reduced for better sensitivity (~4.6 degrees)
        case .headTiltLeft, .headTiltRight:
            return 0.12 // Threshold for head tilt (radians) - balanced sensitivity (~6.9 degrees)
        default:
            return 0.6 // Default threshold for most gestures
        }
    }
    
    /// Commonly used gestures for switch input
    static var commonGestures: [FacialGesture] {
        return [
            .eyeBlinkLeft,
            .eyeBlinkRight,
            .eyeBlinkEither,
            .eyeOpenLeft,
            .eyeOpenRight,
            .eyeOpenEither,
            .jawOpen,
            .mouthClose,
            .mouthSmileLeft,
            .mouthSmileRight,
            .browInnerUp,
            .cheekPuff,
            .mouthPucker,
            .lookUp,
            .lookDown,
            .lookLeft,
            .lookRight,
            .headNodUp,
            .headNodDown,
            .headShakeLeft,
            .headShakeRight
        ]
    }

    /// Converts a linear slider value (0.0-1.0) to a non-linear threshold value (0.1-1.0)
    /// Uses an exponential curve to provide more granular control in the lower sensitivity range
    static func sliderValueToThreshold(_ sliderValue: Float) -> Float {
        // Clamp slider value to valid range
        let clampedValue = max(0.0, min(1.0, sliderValue))

        // Use exponential curve: threshold = 0.1 + 0.9 * (sliderValue^2.5)
        // This gives more granular control in the lower range
        let exponentialValue = pow(clampedValue, 2.5)
        return 0.1 + 0.9 * exponentialValue
    }

    /// Converts a threshold value (0.1-1.0) back to a linear slider value (0.0-1.0)
    /// Inverse of sliderValueToThreshold for proper slider positioning
    static func thresholdToSliderValue(_ threshold: Float) -> Float {
        // Clamp threshold to valid range
        let clampedThreshold = max(0.1, min(1.0, threshold))

        // Inverse of the exponential curve: sliderValue = ((threshold - 0.1) / 0.9)^(1/2.5)
        let normalizedThreshold = (clampedThreshold - 0.1) / 0.9
        return pow(normalizedThreshold, 1.0 / 2.5)
    }
}
