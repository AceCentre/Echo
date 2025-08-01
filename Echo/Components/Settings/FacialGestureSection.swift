//
//  FacialGestureSection.swift
//  Echo
//
//  Created by Will Wade on 04/07/2025.
//

import Foundation
import SwiftData
import SwiftUI
import ARKit
import UIKit
import AudioToolbox



struct FacialGestureSwitchSection: View {
    var gestureSwitch: FacialGestureSwitch

    var body: some View {
        @Bindable var bindableGestureSwitch = gestureSwitch

        if let gesture = gestureSwitch.gesture {
            FacialGestureActionSection(
                gesture: gesture,
                tapAction: $bindableGestureSwitch.tapAction,
                holdAction: $bindableGestureSwitch.holdAction,
                threshold: $bindableGestureSwitch.threshold,
                holdDuration: $bindableGestureSwitch.holdDuration
            )
        }
    }
}

struct FacialGestureActionSection: View {
    let gesture: FacialGesture
    @Binding var tapAction: SwitchAction
    @Binding var holdAction: SwitchAction
    @Binding var threshold: Float
    @Binding var holdDuration: Double

    var body: some View {
        Group {
            // Single gesture action
            ActionPicker(
                label: String(
                    localized: "Single Gesture Action",
                    comment: "The label for the single gesture action picker"
                ),
                actions: SwitchAction.tapCases,
                actionChange: { newAction in
                    tapAction = newAction
                },
                actionState: tapAction
            )


            // Hold gesture action
            ActionPicker(
                label: String(
                    localized: "Hold Gesture Action",
                    comment: "The label for the hold gesture action picker"
                ),
                actions: SwitchAction.holdCases,
                actionChange: { newAction in
                    holdAction = newAction
                },
                actionState: holdAction
            )
            // Threshold slider with context-aware labeling
            VStack(alignment: .leading, spacing: 4) {
                Text(gesture.thresholdLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Low")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Slider(
                        value: Binding(
                            get: { FacialGesture.thresholdToSliderValue(threshold) },
                            set: { threshold = FacialGesture.sliderValueToThreshold($0) }
                        ),
                        in: 0.0...1.0,
                        step: 0.01
                    )
                    .tint(.blue)

                    Text("High")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Context-aware threshold display
                Text(gesture.thresholdDisplayValue(threshold))
                    .font(.caption2)
                    .foregroundColor(.secondary)

                // Helpful description
                Text(gesture.thresholdDescription)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
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
}

struct GesturePreviewSection: View {
    let gesture: FacialGesture
    let threshold: Float
    let holdDuration: Double
    let tapAction: SwitchAction
    let holdAction: SwitchAction
    @ObservedObject var detector: FacialGestureDetector

    @State private var isActive = false
    @State private var lastDetectionState = false
    @State private var gestureStartTime: Date?
    @State private var lastFeedbackType: GestureFeedbackType?

    enum GestureFeedbackType {
        case tap, hold
    }

    // Use @State to force UI updates when gesture values change
    @State private var currentGestureValue: Float = 0.0

    var gestureValue: Float {
        return currentGestureValue
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
                        HStack {
                            Text("Gesture Strength")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(String(format: "%.1f", gestureValue * 100))% / \(String(format: "%.0f", threshold * 100))%")
                                .font(.caption2)
                                .foregroundColor(gestureValue > threshold ? .green : .secondary)
                                .fontWeight(gestureValue > threshold ? .bold : .regular)
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 16)

                                // Current value bar with gradient
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(LinearGradient(
                                        gradient: Gradient(colors: [
                                            .blue,
                                            isGestureDetected ? (isHoldGesture ? .orange : .green) : .orange
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(
                                        width: CGFloat(gestureValue) * geometry.size.width,
                                        height: 16
                                    )
                                    .animation(.easeInOut(duration: 0.1), value: gestureValue)

                                // Threshold indicator line (more prominent)
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: 3, height: 20)
                                    .offset(x: CGFloat(threshold) * geometry.size.width - 1.5)
                                    .shadow(color: .red.opacity(0.3), radius: 2, x: 0, y: 0)

                                // Threshold label
                                Text("Target")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                    .background(
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                    )
                                    .padding(.horizontal, 3)
                                    .padding(.vertical, 1)
                                    .offset(
                                        x: max(15, min(geometry.size.width - 30, CGFloat(threshold) * geometry.size.width - 15)),
                                        y: -15
                                    )
                            }
                        }
                        .frame(height: 20)
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
        .onChange(of: detector.previewGestureValues) { _, newValues in
            let newValue = newValues[gesture] ?? 0.0

            // More intelligent corruption detection: only protect against sudden drops to exactly 0.0
            // after very high values (>0.9) and only for non-gaze gestures
            // This allows natural drops and reduces false positives
            let isGazeGesture = [FacialGesture.lookUp, .lookDown, .lookLeft, .lookRight].contains(gesture)
            if newValue == 0.0 && currentGestureValue > 0.9 && !isGazeGesture {
                EchoLogger.warning("Detected suspicious drop to 0.0 for \(gesture.displayName) (was \(currentGestureValue)) - ignoring", category: .facialGesture)
                return
            }

            if newValue != currentGestureValue {
                currentGestureValue = newValue
            }
        }
        .onChange(of: isGestureDetected) { _, newValue in
            EchoLogger.debug("Gesture detected changed: \(newValue), lastState: \(lastDetectionState)", category: .facialGesture)
            if newValue && !lastDetectionState {
                // Gesture started - record start time but don't play feedback yet
                EchoLogger.debug("Gesture started - waiting for release to determine tap/hold", category: .facialGesture)
                gestureStartTime = Date()
            } else if !newValue && lastDetectionState {
                // Gesture ended - determine if it was tap or hold and play appropriate feedback
                if let startTime = gestureStartTime {
                    let gestureDuration = Date().timeIntervalSince(startTime)
                    let wasHoldGesture = gestureDuration >= holdDuration

                    if wasHoldGesture {
                        EchoLogger.debug("Playing HOLD feedback (duration: \(String(format: "%.1f", gestureDuration))s)", category: .facialGesture)
                        playDetectionFeedback(.hold)
                        lastFeedbackType = .hold
                    } else {
                        EchoLogger.debug("Playing TAP feedback (duration: \(String(format: "%.1f", gestureDuration))s)", category: .facialGesture)
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
        print("Camera permission status: \(detector.cameraPermissionStatus)")
        print("Detector isActive before: \(detector.isActive)")
        print("Detector isPreviewMode before: \(detector.isPreviewMode)")
        detector.startPreviewMode(for: [gesture])
        isActive = true
        print("Preview started, isActive: \(isActive)")
        print("Detector isActive after: \(detector.isActive)")
        print("Detector isPreviewMode after: \(detector.isPreviewMode)")
        print("Detector error message: \(detector.errorMessage ?? "none")")
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

    @Binding var showAddGestureSheet: Bool
    @Binding var currentGestureSwitch: FacialGestureSwitch?
    @State private var isSupported = ARFaceTrackingConfiguration.isSupported
    @StateObject private var gestureDetector = FacialGestureDetector.shared
    @State private var refreshTrigger = false
    
    var body: some View {
        // Hidden view to trigger refresh when refreshTrigger changes
        let _ = refreshTrigger // This forces the view to re-evaluate when refreshTrigger changes

        @Bindable var settingsBindable = settings
        Section(content: {
            // Global Facial Gesture Toggle
            Toggle(
                String(
                    localized: "Facial Gestures",
                    comment: "Toggle to enable/disable all facial gestures"
                ),
                isOn: $settingsBindable.enableFacialGestures
            )

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
                            localized: "This device does not support face tracking. Facial gesture controls require a device with face tracking capability (iPhone X or later, iPad Pro with TrueDepth camera, or devices with A12 Bionic chip or later).",
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
                let visibleGestureSwitches = getVisibleGestureSwitches()

                if !visibleGestureSwitches.isEmpty {
                    ForEach(visibleGestureSwitches, id: \.persistentModelID) { gestureSwitch in
                        Button(action: {
                            currentGestureSwitch = gestureSwitch
                            showAddGestureSheet = true
                        }, label: {
                            HStack {
                                VStack(alignment: .leading) {
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

                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                            }
                        })
                    }
                }

                Button(action: {
                    currentGestureSwitch = nil
                    showAddGestureSheet = true
                }) {
                    HStack {
                        Label(
                            String(
                                localized: "Add Facial Gesture",
                                comment: "Button label to add a new facial gesture switch"
                            ),
                            systemImage: "plus.circle.fill"
                        )                    }
                }
                
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
        .onAppear {
            print("Database marked as ready")
            cleanupDuplicateGestures()
            fixEmptyGestureNames()
        }
        .onChange(of: showAddGestureSheet) { _, newValue in
            if !newValue {
                // Sheet was dismissed, trigger a refresh
                refreshTrigger.toggle()
            }
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

    private func getVisibleGestureSwitches() -> [FacialGestureSwitch] {
        let visibleGestureSwitches = facialGestureSwitches.filter { gestureSwitch in
            // Only show switches that are fully initialized and committed to database
            let hasGesture = gestureSwitch.gesture != nil
            let hasName = !gestureSwitch.name.isEmpty
            return hasGesture && hasName
        }

        return visibleGestureSwitches
    }

    private func fixEmptyGestureNames() {
        print("Fixing empty gesture names...")

        var fixedCount = 0
        for gestureSwitch in facialGestureSwitches {
            if gestureSwitch.name.isEmpty, let gesture = gestureSwitch.gesture {
                print("Fixing empty name for gesture: \(gesture.rawValue) -> \(gesture.displayName)")
                gestureSwitch.name = gesture.displayName
                fixedCount += 1
            }
        }

        if fixedCount > 0 {
            do {
                try modelContext.save()
                print("Fixed \(fixedCount) gestures with empty names")
            } catch {
                print("Failed to fix empty gesture names: \(error)")
            }
        } else {
            print("No gestures with empty names found")
        }
    }

}



struct AddFacialGesture: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var currentGestureSwitch: FacialGestureSwitch?
    let gestureDetector: FacialGestureDetector
    @State private var deleteAlert: Bool = false

    @Environment(\.modelContext) var modelContext
    @Query var facialGestureSwitches: [FacialGestureSwitch]

    @State private var selectedGesture: FacialGesture = .eyeBlinkRight
    @State private var gestureName: String = ""
    @State private var tapAction: SwitchAction = .nextNode
    @State private var holdAction: SwitchAction = .none
    @State private var threshold: Float = 0.8
    @State private var holdDuration: Double = 1.0

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

                    NavigationLink(destination: {
                        AnatomicalFacialGesturePicker(
                            selectedGesture: Binding(
                                get: { bindableGestureSwitch.gesture ?? .eyeBlinkLeft },
                                set: { bindableGestureSwitch.gesture = $0 }
                            )
                        )
                    }) {
                        HStack {
                            Text(String(
                                localized: "Facial Gesture",
                                comment: "Label for gesture type picker"
                            ))
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text((bindableGestureSwitch.gesture ?? .eyeBlinkLeft).displayName)
                                    .foregroundColor(.secondary)
                                Text((bindableGestureSwitch.gesture ?? .eyeBlinkLeft).description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }

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
                            dismiss()
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

                    NavigationLink(destination: {
                        AnatomicalFacialGesturePicker(selectedGesture: $selectedGesture)
                    }) {
                        HStack {
                            Text(String(
                                localized: "Facial Gesture",
                                comment: "Label for gesture type picker"
                            ))
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(selectedGesture.displayName)
                                    .foregroundColor(.secondary)
                                Text(selectedGesture.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                    }

                }, header: {
                    Text("New Gesture", comment: "Header for new gesture section")
                })

                // Actions section for new gesture
                Section(content: {
                    FacialGestureActionSection(
                        gesture: selectedGesture,
                        tapAction: $tapAction,
                        holdAction: $holdAction,
                        threshold: $threshold,
                        holdDuration: $holdDuration
                    )
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
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Save", comment: "Save button")) {
                    saveGesture()
                    dismiss()
                }
                .disabled(currentGestureSwitch == nil && gestureName.isEmpty)
            }
        }
        .onAppear {
            if currentGestureSwitch == nil {
                // Set default name for new gesture
                gestureName = selectedGesture.displayName
            } else {
                // Initialize state variables with existing gesture values
                if let existingGesture = currentGestureSwitch {
                    print("📖 Loading existing gesture '\(existingGesture.displayName)':")
                    print("   loaded tapAction: \(existingGesture.tapAction.title)")
                    print("   loaded holdAction: \(existingGesture.holdAction.title)")
                    print("   loaded threshold: \(existingGesture.threshold)")
                    print("   loaded holdDuration: \(existingGesture.holdDuration)")

                    gestureName = existingGesture.name
                    selectedGesture = existingGesture.gesture ?? .eyeBlinkRight
                    tapAction = existingGesture.tapAction
                    holdAction = existingGesture.holdAction
                    threshold = existingGesture.threshold
                    holdDuration = existingGesture.holdDuration
                }
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
                print("💾 Saving existing gesture '\(currentGestureSwitch.displayName)':")
                print("   current tapAction in object: \(currentGestureSwitch.tapAction.title)")
                print("   current holdAction in object: \(currentGestureSwitch.holdAction.title)")
                print("   current threshold in object: \(currentGestureSwitch.threshold)")
                print("   current holdDuration in object: \(currentGestureSwitch.holdDuration)")

                // For existing gestures, only update name and gesture type
                // The actions, threshold, and holdDuration are already updated via @Bindable in FacialGestureSwitchSection
                currentGestureSwitch.name = gestureName
                currentGestureSwitch.gesture = selectedGesture

                print("💾 Final values before save:")
                print("   final tapAction: \(currentGestureSwitch.tapAction.title)")
                print("   final holdAction: \(currentGestureSwitch.holdAction.title)")
            }
        }

        do {
            try modelContext.save()
            print("Successfully saved gesture: \(selectedGesture.displayName)")

            // Verify what was actually saved
            if let currentGestureSwitch = currentGestureSwitch {
                print("✅ Verification after save:")
                print("   saved tapAction: \(currentGestureSwitch.tapAction.title)")
                print("   saved holdAction: \(currentGestureSwitch.holdAction.title)")
            }
        } catch {
            print("Failed to save facial gesture switch: \(error)")
            print("Error details: \(error.localizedDescription)")
        }
    }
}
