//
//  AnatomicalFacialGesturePicker.swift
//  Echo
//
//  Created by Will Wade on 07/07/2025.
//

import SwiftUI
import ARKit

struct AnatomicalFacialGesturePicker: View {
    @Binding var selectedGesture: FacialGesture
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                // Auto Select Section
                Section(content: {
                    if ARFaceTrackingConfiguration.isSupported {
                        NavigationLink(destination: {
                            AutoSelectFacialGestureView(selectedGesture: $selectedGesture)
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Auto Select Facial Gesture")
                                        .font(.headline)
                                    Text("Let the camera detect your gesture automatically")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "camera.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                    } else {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Auto Select Facial Gesture")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Requires device with TrueDepth camera")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "camera.slash")
                                .foregroundColor(.secondary)
                        }
                    }
                }, header: {
                    Text("Automatic Detection", comment: "Header for auto-detection section")
                }, footer: {
                    if ARFaceTrackingConfiguration.isSupported {
                        Text("Position your face in the camera, follow the countdown, then make your gesture. The app will automatically detect and select it.", comment: "Footer explaining auto-detection")
                    } else {
                        Text("Auto-detection requires a device with Face ID capability (iPhone X or later, iPad Pro with TrueDepth camera). Use manual selection below.", comment: "Footer explaining auto-detection unavailable")
                    }
                })

                Section(content: {
                    ForEach(FacialGestureCategory.allCases) { category in
                        NavigationLink(destination: {
                            FacialGestureCategoryView(
                                category: category,
                                selectedGesture: $selectedGesture
                            )
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(category.displayName)
                                        .font(.headline)
                                    Text(category.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if category.gestures.contains(selectedGesture) {
                                    Text(selectedGesture.displayName)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }, header: {
                    Text("Select Facial Gesture by Area", comment: "Header for anatomical gesture selection")
                }, footer: {
                    Text("Choose a facial area to see available gestures for that region", comment: "Footer explaining anatomical gesture selection")
                })
            }
            .navigationTitle("Facial Gesture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FacialGestureCategoryView: View {
    let category: FacialGestureCategory
    @Binding var selectedGesture: FacialGesture
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section(content: {
                ForEach(category.gestures) { gesture in
                    Button(action: {
                        selectedGesture = gesture
                        // Dismiss twice to go back to the main form
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dismiss()
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(gesture.displayName)
                                    .foregroundColor(.primary)
                                    .font(.body)
                                Text(gesture.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            if gesture == selectedGesture {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }, header: {
                Text(category.displayName)
            }, footer: {
                Text(category.description)
            })
        }
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

enum FacialGestureCategory: String, CaseIterable, Identifiable {
    case eyes = "eyes"
    case eyebrows = "eyebrows" 
    case cheeks = "cheeks"
    case jaw = "jaw"
    case mouth = "mouth"
    case nose = "nose"
    case tongue = "tongue"
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .eyes: return String(
            localized: "Eyes",
            comment: "Category name for eye gestures"
        )
        case .eyebrows: return String(
            localized: "Eyebrows",
            comment: "Category name for eyebrow gestures"
        )
        case .cheeks: return String(
            localized: "Cheeks", 
            comment: "Category name for cheek gestures"
        )
        case .jaw: return String(
            localized: "Jaw",
            comment: "Category name for jaw gestures"
        )
        case .mouth: return String(
            localized: "Mouth",
            comment: "Category name for mouth gestures"
        )
        case .nose: return String(
            localized: "Nose",
            comment: "Category name for nose gestures"
        )
        case .tongue: return String(
            localized: "Tongue",
            comment: "Category name for tongue gestures"
        )
        }
    }
    
    var description: String {
        switch self {
        case .eyes: return String(
            localized: "Blinking and eye movements",
            comment: "Description for eye gesture category"
        )
        case .eyebrows: return String(
            localized: "Eyebrow raises and movements",
            comment: "Description for eyebrow gesture category"
        )
        case .cheeks: return String(
            localized: "Cheek puffs and squints",
            comment: "Description for cheek gesture category"
        )
        case .jaw: return String(
            localized: "Jaw movements and mouth opening",
            comment: "Description for jaw gesture category"
        )
        case .mouth: return String(
            localized: "Lip movements, smiles, and expressions",
            comment: "Description for mouth gesture category"
        )
        case .nose: return String(
            localized: "Nose movements and sneers",
            comment: "Description for nose gesture category"
        )
        case .tongue: return String(
            localized: "Tongue movements",
            comment: "Description for tongue gesture category"
        )
        }
    }
    
    var gestures: [FacialGesture] {
        switch self {
        case .eyes:
            return [.eyeBlinkLeft, .eyeBlinkRight, .eyeBlinkEither]
        case .eyebrows:
            return [.browDownLeft, .browDownRight, .browInnerUp, .browOuterUpLeft, .browOuterUpRight]
        case .cheeks:
            return [.cheekPuff, .cheekSquintLeft, .cheekSquintRight]
        case .jaw:
            return [.jawForward, .jawLeft, .jawRight, .jawOpen]
        case .mouth:
            return [
                .mouthClose, .mouthFunnel, .mouthPucker, .mouthLeft, .mouthRight,
                .mouthSmileLeft, .mouthSmileRight, .mouthFrownLeft, .mouthFrownRight,
                .mouthDimpleLeft, .mouthDimpleRight, .mouthStretchLeft, .mouthStretchRight,
                .mouthRollLower, .mouthRollUpper, .mouthShrugLower, .mouthShrugUpper,
                .mouthPressLeft, .mouthPressRight, .mouthLowerDownLeft, .mouthLowerDownRight,
                .mouthUpperUpLeft, .mouthUpperUpRight
            ]
        case .nose:
            return [.noseSneerLeft, .noseSneerRight]
        case .tongue:
            return [.tongueOut]
        }
    }
}

#Preview {
    AnatomicalFacialGesturePicker(selectedGesture: .constant(.eyeBlinkLeft))
}
