//
//  FacialGestureSection.swift
//  Echo
//
//  Created by Augment Agent on 04/07/2025.
//

import Foundation
import SwiftData
import SwiftUI
import ARKit
import UIKit
import AudioToolbox

struct FacialGestureSwitchSection: View {
    @State var tapAction: SwitchAction
    @State var holdAction: SwitchAction
    @State var threshold: Float
    @State var holdDuration: Double
    @State var isEnabled: Bool

    var gestureSwitch: FacialGestureSwitch

    init(gestureSwitch: FacialGestureSwitch) {
        self.gestureSwitch = gestureSwitch
        self._tapAction = State(initialValue: gestureSwitch.tapAction)
        self._holdAction = State(initialValue: gestureSwitch.holdAction)
        self._threshold = State(initialValue: gestureSwitch.threshold)
        self._holdDuration = State(initialValue: gestureSwitch.holdDuration)
        self._isEnabled = State(initialValue: gestureSwitch.isEnabled)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Enable/Disable toggle
            Toggle(
                String(
                    localized: "Enable Gesture",
                    comment: "Toggle to enable/disable facial gesture"
                ),
                isOn: $isEnabled
            )
            
            if isEnabled {
                // Tap action picker
                ActionPicker(
                    label: String(
                        localized: "Single Gesture",
                        comment: "The label that is shown next to the single gesture action"
                    ),
                    actions: SwitchAction.tapCases,
                    actionChange: { newAction in
                        tapAction = newAction
                    },
                    actionState: tapAction
                )

                // Hold action picker
                ActionPicker(
                    label: String(
                        localized: "Hold Gesture",
                        comment: "The label that is shown next to the hold gesture action"
                    ),
                    actions: SwitchAction.holdCases,
                    actionChange: { newAction in
                        holdAction = newAction
                    },
                    actionState: holdAction
                )
                
                // Threshold slider
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(
                        localized: "Sensitivity",
                        comment: "Label for gesture sensitivity slider"
                    ))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    HStack {
                        Text("Low")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $threshold, in: 0.1...1.0, step: 0.1)
                            .tint(.blue)
                        
                        Text("High")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(String(
                        localized: "Threshold: \(String(format: "%.1f", threshold))",
                        comment: "Shows current threshold value"
                    ))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }


                
                // Hold duration slider (only if hold action is not .none)
                if holdAction != .none {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(
                            localized: "Hold Duration",
                            comment: "Label for hold duration slider"
                        ))
                        .font(.caption)
                        .foregroundColor(.secondary)

                        HStack {
                            Text("0.5s")
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Slider(value: $holdDuration, in: 0.5...3.0, step: 0.1)
                                .tint(.blue)

                            Text("3.0s")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        Text(String(
                            localized: "Duration: \(String(format: "%.1f", holdDuration))s",
                            comment: "Shows current hold duration value"
                        ))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    }
                }

                // Explanatory text about tap/hold behavior
                if holdAction != .none {
                    Text("Actions trigger when gesture is released: Quick release = Tap action, Hold past duration = Hold action")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
            }
        }
        .onChange(of: tapAction) { _, _ in
            gestureSwitch.tapAction = tapAction
        }
        .onChange(of: holdAction) { _, _ in
            gestureSwitch.holdAction = holdAction
        }
        .onChange(of: threshold) { _, _ in
            gestureSwitch.threshold = threshold
        }
        .onChange(of: holdDuration) { _, _ in
            gestureSwitch.holdDuration = holdDuration
        }
        .onChange(of: isEnabled) { _, _ in
            gestureSwitch.isEnabled = isEnabled
        }
    }
}


struct GesturePreviewSection: View {
    let gesture: FacialGesture
    let threshold: Float
    let holdDuration: Double
    let tapAction: SwitchAction
    let holdAction: SwitchAction
    let detector: FacialGestureDetector

    @State private var isActive = false
    @State private var lastDetectionState = false
    @State private var gestureStartTime: Date?
    @State private var lastFeedbackType: GestureFeedbackType?

    enum GestureFeedbackType {
        case tap, hold
    }

    var gestureValue: Float {
        detector.previewGestureValues[gesture] ?? 0.0
    }

    var isGestureDetected: Bool {
        gestureValue >= threshold
    }

    var gestureHoldTime: TimeInterval {
        guard let startTime = gestureStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }

    var isHoldGesture: Bool {
        isGestureDetected && gestureHoldTime >= holdDuration
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Test Gesture")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    if isActive {
                        stopPreview()
                    } else {
                        startPreview()
                    }
                }) {
                    Text(isActive ? "Stop" : "Start")
                        .font(.caption)
                        .foregroundColor(isActive ? .red : .blue)
                }
            }

            if isActive {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Strength: \(Int(gestureValue * 100))%")
                            .font(.caption2)
                        Spacer()
                        if isGestureDetected {
                            if let startTime = gestureStartTime {
                                let currentDuration = Date().timeIntervalSince(startTime)
                                if currentDuration >= holdDuration {
                                    Text("HOLD READY")
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                        .fontWeight(.bold)
                                } else {
                                    Text("BUILDING... \(String(format: "%.1f", currentDuration))s")
                                        .font(.caption2)
                                        .foregroundColor(.blue)
                                        .fontWeight(.bold)
                                }
                            } else {
                                Text("DETECTED")
                                    .font(.caption2)
                                    .foregroundColor(.green)
                                    .fontWeight(.bold)
                            }
                        }
                    }

                    // Gesture strength progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Gesture Strength")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)

                                Rectangle()
                                    .fill(isGestureDetected ? (isHoldGesture ? Color.orange : Color.green) : Color.blue)
                                    .frame(width: CGFloat(gestureValue) * geometry.size.width, height: 4)
                                    .animation(.easeInOut(duration: 0.1), value: gestureValue)
                            }
                        }
                        .frame(height: 4)
                    }

                    // Hold duration progress (always show if hold action is configured)
                    if holdAction != .none {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Hold Progress")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(String(format: "%.1f", gestureHoldTime))s / \(String(format: "%.1f", holdDuration))s")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 4)

                                    Rectangle()
                                        .fill(isHoldGesture ? Color.orange : (isGestureDetected ? Color.blue : Color.clear))
                                        .frame(width: CGFloat(min(gestureHoldTime / holdDuration, 1.0)) * geometry.size.width, height: 4)
                                        .animation(.easeInOut(duration: 0.1), value: gestureHoldTime)
                                }
                            }
                            .frame(height: 4)
                        }
                    }

                    // Show which action would be triggered
                    HStack {
                        Text("Action:")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        if isGestureDetected {
                            if isHoldGesture && holdAction != .none {
                                Text(holdAction.title)
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                    .fontWeight(.medium)
                            } else if !isHoldGesture && tapAction != .none {
                                Text(tapAction.title)
                                    .font(.caption2)
                                    .foregroundColor(.green)
                                    .fontWeight(.medium)
                            } else {
                                Text("None")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            Text("Waiting for gesture...")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .onDisappear {
            stopPreview()
        }
        .onChange(of: gestureValue) { _, newValue in
            print("Gesture value changed: \(newValue), threshold: \(threshold)")
        }
        .onChange(of: isGestureDetected) { _, newValue in
            print("Gesture detected changed: \(newValue), lastState: \(lastDetectionState)")
            if newValue && !lastDetectionState {
                // Gesture started - record start time but don't play feedback yet
                print("Gesture started - waiting for release to determine tap/hold")
                gestureStartTime = Date()
            } else if !newValue && lastDetectionState {
                // Gesture ended - determine if it was tap or hold and play appropriate feedback
                if let startTime = gestureStartTime {
                    let gestureDuration = Date().timeIntervalSince(startTime)
                    let wasHoldGesture = gestureDuration >= holdDuration

                    if wasHoldGesture {
                        print("Playing HOLD feedback (duration: \(String(format: "%.1f", gestureDuration))s)")
                        playDetectionFeedback(.hold)
                        lastFeedbackType = .hold
                    } else {
                        print("Playing TAP feedback (duration: \(String(format: "%.1f", gestureDuration))s)")
                        playDetectionFeedback(.tap)
                        lastFeedbackType = .tap
                    }
                }

                gestureStartTime = nil
                lastFeedbackType = nil
            }
            lastDetectionState = newValue
        }

    }

    private func startPreview() {
        print("Starting preview for gesture: \(gesture.displayName)")
        print("Detector supported: \(detector.isSupported)")
        detector.startPreviewMode(for: [gesture])
        isActive = true
        print("Preview started, isActive: \(isActive)")
    }

    private func stopPreview() {
        print("Stopping preview")
        detector.stopPreviewMode()
        isActive = false
        print("Preview stopped, isActive: \(isActive)")
    }

    private func playDetectionFeedback(_ type: GestureFeedbackType) {
        print("playDetectionFeedback called with type: \(type)")

        switch type {
        case .tap:
            // Tap gesture: Use keyboard click sound + light haptic
            print("Playing tap sound (1104 - keyboard click) and light haptic")
            AudioServicesPlaySystemSound(1104) // Keyboard click

            // Also try the peek sound as backup
            AudioServicesPlaySystemSound(1519) // Peek sound

            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()

        case .hold:
            // Hold gesture: Use pop sound + stronger haptic
            print("Playing hold sound (1520 - pop) and heavy haptic")
            AudioServicesPlaySystemSound(1520) // Pop sound

            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }

        print("Feedback completed - Check: Silent switch off? System sounds enabled?")
    }
}

struct FacialGestureSection: View {
    @Environment(\.modelContext) var modelContext
    @Environment(Settings.self) var settings: Settings
    @Query var facialGestureSwitches: [FacialGestureSwitch]

    @State private var currentGestureSwitch: FacialGestureSwitch?
    @State private var showAddGestureSheet = false
    @State private var isSupported = ARFaceTrackingConfiguration.isSupported
    @StateObject private var gestureDetector = FacialGestureDetector()
    
    var body: some View {
        Section(content: {
            if !isSupported {
                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        String(
                            localized: "Face Tracking Not Supported",
                            comment: "Title for unsupported device message"
                        ),
                        systemImage: "exclamationmark.triangle"
                    )
                    .foregroundColor(.orange)
                    
                    Text(
                        String(
                            localized: "This device does not support face tracking. Facial gesture controls require a device with TrueDepth camera or A12 Bionic chip or later.",
                            comment: "Explanation for unsupported device"
                        )
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
            } else if gestureDetector.cameraPermissionStatus == .denied {
                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        String(
                            localized: "Camera Access Denied",
                            comment: "Title for camera permission denied message"
                        ),
                        systemImage: "camera.fill"
                    )
                    .foregroundColor(.red)

                    Text(
                        String(
                            localized: "Facial gesture controls require camera access. Please enable camera access in Settings > Privacy & Security > Camera > Echo.",
                            comment: "Explanation for camera permission denied"
                        )
                    )
                    .font(.caption)
                    .foregroundColor(.secondary)

                    Button(action: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }) {
                        Text("Open Settings", comment: "Button to open app settings")
                            .font(.caption)
                    }
                }
            } else {
                ForEach(facialGestureSwitches.filter { gestureSwitch in
                    // Only show switches that are fully initialized and committed to database
                    return gestureSwitch.gesture != nil &&
                           !gestureSwitch.name.isEmpty &&
                           !gestureSwitch.isDeleted
                }, id: \.persistentModelID) { gestureSwitch in
                    Button(action: {
                        currentGestureSwitch = gestureSwitch
                        showAddGestureSheet.toggle()
                    }, label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(gestureSwitch.displayName.isEmpty ? gestureSwitch.name : gestureSwitch.displayName)
                                    .foregroundColor(.primary)

                                if let gesture = gestureSwitch.gesture {
                                    let description = gesture.description
                                    Text(description.isEmpty ? gesture.rawValue : description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            // Status indicator
                            Circle()
                                .fill(gestureSwitch.isEnabled ? Color.green : Color.gray)
                                .frame(width: 8, height: 8)

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                    })
                }
                
                Button(action: {
                    currentGestureSwitch = nil
                    showAddGestureSheet.toggle()
                }, label: {
                    Label(
                        String(
                            localized: "Add Facial Gesture",
                            comment: "Button label to add a new facial gesture switch"
                        ),
                        systemImage: "plus.circle.fill"
                    )
                })








            }
        }, header: {
            Text("Facial Gestures", comment: "Header for facial gesture settings area")
        }, footer: {
            if isSupported {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Use facial movements to control Echo. Ensure good lighting and position your face clearly in view of the front camera.", comment: "Footer for facial gesture settings area")

                    if gestureDetector.isActive {
                        HStack {
                            Circle()
                                .fill(.green)
                                .frame(width: 8, height: 8)
                            Text("Camera active", comment: "Status text when camera is active")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }

                    if let errorMessage = gestureDetector.errorMessage {
                        Text(errorMessage)
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
            }
        })
        AddFacialGestureSheet(
            showAddGestureSheet: $showAddGestureSheet,
            currentGestureSwitch: $currentGestureSwitch,
            gestureDetector: gestureDetector
        )
        .onAppear {
            print("Database marked as ready")
            cleanupDuplicateGestures()
        }
        .onChange(of: showAddGestureSheet) { _, newValue in
            print("showAddGestureSheet changed to: \(newValue)")
        }
    }

    private func cleanupDuplicateGestures() {
        print("Cleaning up duplicate gestures...")

        // Group gestures by their gesture type
        var gestureGroups: [String: [FacialGestureSwitch]] = [:]
        for gestureSwitch in facialGestureSwitches {
            let gestureKey = gestureSwitch.gestureRaw
            if gestureGroups[gestureKey] == nil {
                gestureGroups[gestureKey] = []
            }
            gestureGroups[gestureKey]?.append(gestureSwitch)
        }

        // Remove duplicates (keep only the first one of each type)
        var removedCount = 0
        for (gestureType, switches) in gestureGroups {
            if switches.count > 1 {
                print("Found \(switches.count) duplicates of \(gestureType), removing \(switches.count - 1)")
                // Keep the first one, remove the rest
                for i in 1..<switches.count {
                    modelContext.delete(switches[i])
                    removedCount += 1
                }
            }
        }

        if removedCount > 0 {
            do {
                try modelContext.save()
                print("Removed \(removedCount) duplicate gestures")
            } catch {
                print("Failed to remove duplicate gestures: \(error)")
            }
        } else {
            print("No duplicate gestures found")
        }
    }

}

struct AddFacialGestureSheet: View {
    @Binding var showAddGestureSheet: Bool
    @Binding var currentGestureSwitch: FacialGestureSwitch?
    let gestureDetector: FacialGestureDetector

    var body: some View {
        ZStack {}
            .sheet(isPresented: $showAddGestureSheet, onDismiss: {
                // Reset all state when sheet is dismissed
                print("Sheet dismissed, resetting state")
                currentGestureSwitch = nil
            }) {
                AddFacialGesture(currentGestureSwitch: $currentGestureSwitch, gestureDetector: gestureDetector)
            }
    }
}

struct AddFacialGesture: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var currentGestureSwitch: FacialGestureSwitch?
    let gestureDetector: FacialGestureDetector
    @State private var deleteAlert: Bool = false

    @Environment(\.modelContext) var modelContext
    @Query var facialGestureSwitches: [FacialGestureSwitch]

    @State private var selectedGesture: FacialGesture = .eyeBlinkLeft
    @State private var gestureName: String = ""
    @State private var tapAction: SwitchAction = .nextNode
    @State private var holdAction: SwitchAction = .none
    @State private var threshold: Float = 0.8
    @State private var holdDuration: Double = 1.0
    @State private var isEnabled: Bool = false

    var body: some View {
        NavigationStack {
            Form {
            if let unwrappedGestureSwitch = currentGestureSwitch {
                @Bindable var bindableGestureSwitch = unwrappedGestureSwitch

                Section(content: {
                    TextField(
                        String(
                            localized: "Gesture Name",
                            comment: "Placeholder for gesture name field"
                        ),
                        text: $bindableGestureSwitch.name
                    )

                    Picker(
                        String(
                            localized: "Facial Gesture",
                            comment: "Label for gesture type picker"
                        ),
                        selection: Binding(
                            get: { bindableGestureSwitch.gesture ?? .eyeBlinkLeft },
                            set: { bindableGestureSwitch.gesture = $0 }
                        )
                    ) {
                        ForEach(FacialGesture.allCases) { gesture in
                            VStack(alignment: .leading) {
                                Text(gesture.displayName)
                                Text(gesture.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(gesture)
                        }
                    }
                    .pickerStyle(.menu)

                }, header: {
                    Text("Gesture Configuration", comment: "Header for gesture configuration section")
                })

                Section(content: {
                    FacialGestureSwitchSection(gestureSwitch: unwrappedGestureSwitch)
                }, header: {
                    Text("Actions", comment: "Header for actions section")
                })

                // Preview section for existing gesture
                if let gesture = unwrappedGestureSwitch.gesture, ARFaceTrackingConfiguration.isSupported {
                    Section(content: {
                        GesturePreviewSection(
                            gesture: gesture,
                            threshold: unwrappedGestureSwitch.threshold,
                            holdDuration: unwrappedGestureSwitch.holdDuration,
                            tapAction: unwrappedGestureSwitch.tapAction,
                            holdAction: unwrappedGestureSwitch.holdAction,
                            detector: gestureDetector
                        )
                    }, header: {
                        Text("Preview", comment: "Header for gesture preview section")
                    })
                }

                Section(content: {
                    Button(action: {
                        deleteAlert = true
                    }, label: {
                        Label(
                            String(
                                localized: "Delete Gesture",
                                comment: "The label for the button to delete a facial gesture"
                            ),
                            systemImage: "trash"
                        )
                        .foregroundColor(.red)
                    })
                    .alert(String(localized: "Delete Gesture", comment: "Title for alert about deleting a gesture"), isPresented: $deleteAlert) {
                        Button(String(localized: "Delete", comment: "Button label to confirm deletion"), role: .destructive) {
                            if let unwrappedGestureSwitch = currentGestureSwitch {
                                modelContext.delete(unwrappedGestureSwitch)
                                currentGestureSwitch = nil
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                        Button(String(localized: "Cancel", comment: "Cancel button label"), role: .cancel) {
                            deleteAlert.toggle()
                        }
                    } message: {
                        Text("This will permanently delete this facial gesture switch.", comment: "Message for delete gesture alert")
                    }
                })

            } else {
                // Creating new gesture switch
                Section(content: {
                    TextField(
                        String(
                            localized: "Gesture Name",
                            comment: "Placeholder for gesture name field"
                        ),
                        text: $gestureName
                    )

                    Picker(
                        String(
                            localized: "Facial Gesture",
                            comment: "Label for gesture type picker"
                        ),
                        selection: $selectedGesture
                    ) {
                        ForEach(FacialGesture.allCases) { gesture in
                            VStack(alignment: .leading) {
                                Text(gesture.displayName)
                                Text(gesture.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(gesture)
                        }
                    }
                    .pickerStyle(.menu)

                }, header: {
                    Text("New Gesture", comment: "Header for new gesture section")
                })

                // Actions section for new gesture
                Section(content: {
                        // Tap action picker
                        ActionPicker(
                            label: String(
                                localized: "Single Gesture",
                                comment: "The label that is shown next to the single gesture action"
                            ),
                            actions: SwitchAction.tapCases,
                            actionChange: { newAction in
                                tapAction = newAction
                            },
                            actionState: tapAction
                        )

                        // Hold action picker
                        ActionPicker(
                            label: String(
                                localized: "Hold Gesture",
                                comment: "The label that is shown next to the hold gesture action"
                            ),
                            actions: SwitchAction.holdCases,
                            actionChange: { newAction in
                                holdAction = newAction
                            },
                            actionState: holdAction
                        )

                        // Sensitivity slider
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(
                                localized: "Sensitivity",
                                comment: "Label for gesture sensitivity slider"
                            ))
                            .font(.caption)
                            .foregroundColor(.secondary)

                            HStack {
                                Text("Low")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                Slider(value: $threshold, in: 0.1...1.0, step: 0.05)
                                    .tint(.blue)

                                Text("High")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Text(String(
                                localized: "Threshold: \(Int(threshold * 100))%",
                                comment: "Shows current threshold value"
                            ))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }

                        // Hold duration slider (only if hold action is not .none)
                        if holdAction != .none {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(
                                    localized: "Hold Duration",
                                    comment: "Label for hold duration slider"
                                ))
                                .font(.caption)
                                .foregroundColor(.secondary)

                                HStack {
                                    Text("0.5s")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)

                                    Slider(value: $holdDuration, in: 0.5...3.0, step: 0.1)
                                        .tint(.blue)

                                    Text("3.0s")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }

                                Text(String(
                                    localized: "Duration: \(String(format: "%.1f", holdDuration))s",
                                    comment: "Shows current hold duration value"
                                ))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            }
                        }

                    // Explanatory text about tap/hold behavior
                    if holdAction != .none {
                        Text("Actions trigger when gesture is released: Quick release = Tap action, Hold past duration = Hold action")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }, header: {
                    Text("Actions", comment: "Header for actions section")
                })

                // Preview section for new gesture
                if ARFaceTrackingConfiguration.isSupported {
                    Section(content: {
                        GesturePreviewSection(
                            gesture: selectedGesture,
                            threshold: threshold,
                            holdDuration: holdDuration,
                            tapAction: tapAction,
                            holdAction: holdAction,
                            detector: gestureDetector
                        )
                    }, header: {
                        Text("Preview", comment: "Header for gesture preview section")
                    })
                }
            }
        }
        .navigationTitle(
            currentGestureSwitch != nil ?
            String(localized: "Edit Gesture", comment: "Navigation title for editing gesture") :
            String(localized: "Add Gesture", comment: "Navigation title for adding gesture")
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "Cancel", comment: "Cancel button")) {
                    presentationMode.wrappedValue.dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Save", comment: "Save button")) {
                    saveGesture()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(currentGestureSwitch == nil && gestureName.isEmpty)
            }
        }
        .onAppear {
            if currentGestureSwitch == nil {
                // Set default name for new gesture
                gestureName = selectedGesture.displayName
            }
        }
        .onChange(of: selectedGesture) { _, newGesture in
            if currentGestureSwitch == nil && gestureName.isEmpty {
                gestureName = newGesture.displayName
            }
        }
        }
    }

    private func saveGesture() {
        if currentGestureSwitch == nil {
            // Check for duplicate gestures (only for new gestures)
            print("Checking for duplicates of: \(selectedGesture.rawValue)")
            print("Existing gestures:")
            for existingSwitch in facialGestureSwitches {
                print("  - \(existingSwitch.gestureRaw) (\(existingSwitch.gesture?.displayName ?? "nil"))")
            }

            let existingGesture = facialGestureSwitches.first { $0.gesture == selectedGesture }
            if existingGesture != nil {
                print("DUPLICATE FOUND: Cannot create duplicate gesture: \(selectedGesture.displayName)")
                print("Existing gesture: \(existingGesture?.gestureRaw ?? "unknown")")
                // TODO: Show user-facing error alert
                return
            }

            print("No duplicate found, proceeding with creation")

            // Create new gesture switch with all configured settings
            let newGestureSwitch = FacialGestureSwitch(
                name: gestureName.isEmpty ? selectedGesture.displayName : gestureName,
                gesture: selectedGesture,
                threshold: threshold,
                tapAction: tapAction,
                holdAction: holdAction,
                isEnabled: true, // Enable by default when creating
                holdDuration: holdDuration
            )
            modelContext.insert(newGestureSwitch)
            currentGestureSwitch = newGestureSwitch
        } else {
            // Update existing gesture switch
            if let currentGestureSwitch = currentGestureSwitch {
                currentGestureSwitch.name = gestureName
                currentGestureSwitch.gesture = selectedGesture
                currentGestureSwitch.threshold = threshold
                currentGestureSwitch.tapAction = tapAction
                currentGestureSwitch.holdAction = holdAction
                currentGestureSwitch.holdDuration = holdDuration
            }
        }

        do {
            try modelContext.save()
            print("Successfully saved gesture: \(selectedGesture.displayName)")
        } catch {
            print("Failed to save facial gesture switch: \(error)")
        }
    }
}
