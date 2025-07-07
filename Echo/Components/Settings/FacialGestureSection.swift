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

    @StateObject private var detector = FacialGestureDetector()
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
                            if isHoldGesture {
                                Text("🔶 HOLD")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                    .fontWeight(.bold)
                            } else {
                                Text("✓ TAP")
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
            print("🔊 Gesture value changed: \(newValue), threshold: \(threshold)")
        }
        .onChange(of: isGestureDetected) { _, newValue in
            print("🔊 Gesture detected changed: \(newValue), lastState: \(lastDetectionState)")
            if newValue && !lastDetectionState {
                // Gesture started - record start time and play tap feedback
                print("🔊 Playing TAP feedback")
                gestureStartTime = Date()
                playDetectionFeedback(.tap)
                lastFeedbackType = .tap
            } else if !newValue && lastDetectionState {
                // Gesture ended - reset timing
                print("🔊 Gesture ended")
                gestureStartTime = nil
                lastFeedbackType = nil
            }
            lastDetectionState = newValue
        }
        .onChange(of: isHoldGesture) { _, newValue in
            print("🔊 Hold gesture changed: \(newValue), lastFeedback: \(String(describing: lastFeedbackType))")
            if newValue && lastFeedbackType != .hold {
                // Hold threshold reached - play hold feedback
                print("🔊 Playing HOLD feedback")
                playDetectionFeedback(.hold)
                lastFeedbackType = .hold
            }
        }
    }

    private func startPreview() {
        print("🔊 Starting preview for gesture: \(gesture.displayName)")
        print("🔊 Detector supported: \(detector.isSupported)")
        detector.startPreviewMode(for: [gesture])
        isActive = true
        print("🔊 Preview started, isActive: \(isActive)")
    }

    private func stopPreview() {
        print("🔊 Stopping preview")
        detector.stopPreviewMode()
        isActive = false
        print("🔊 Preview stopped, isActive: \(isActive)")
    }

    private func playDetectionFeedback(_ type: GestureFeedbackType) {
        print("🔊 playDetectionFeedback called with type: \(type)")

        switch type {
        case .tap:
            // Tap gesture: Use keyboard click sound + light haptic
            print("🔊 Playing tap sound (1104 - keyboard click) and light haptic")
            AudioServicesPlaySystemSound(1104) // Keyboard click

            // Also try the peek sound as backup
            AudioServicesPlaySystemSound(1519) // Peek sound

            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()

        case .hold:
            // Hold gesture: Use pop sound + stronger haptic
            print("🔊 Playing hold sound (1520 - pop) and heavy haptic")
            AudioServicesPlaySystemSound(1520) // Pop sound

            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.prepare()
            impactFeedback.impactOccurred()
        }

        print("🔊 Feedback completed - Check: Silent switch off? System sounds enabled?")
    }
}

struct FacialGestureSection: View {
    @Environment(\.modelContext) var modelContext
    @Environment(Settings.self) var settings: Settings
    @Query var facialGestureSwitches: [FacialGestureSwitch]

    @State private var currentGestureSwitch: FacialGestureSwitch?
    @State private var showAddGestureSheet = false
    @State private var isSupported = ARFaceTrackingConfiguration.isSupported
    @State private var lastTapTime: Date = Date()
    @State private var isDatabaseReady = false
    @State private var isSheetPresenting = false
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
                }, id: \.gestureRaw) { gestureSwitch in
                    Button(action: {
                        // Prevent multiple presentations and rapid tapping
                        let now = Date()
                        guard !showAddGestureSheet &&
                              !isSheetPresenting &&
                              now.timeIntervalSince(lastTapTime) > 0.5 &&
                              isDatabaseReady else {
                            print("🐛 Button tap blocked - showSheet: \(showAddGestureSheet), presenting: \(isSheetPresenting), timeSince: \(now.timeIntervalSince(lastTapTime)), dbReady: \(isDatabaseReady)")
                            return
                        }

                        print("🐛 Opening sheet for gesture: \(gestureSwitch.name)")
                        lastTapTime = now
                        isSheetPresenting = true
                        currentGestureSwitch = gestureSwitch

                        // Small delay to ensure state is stable and prevent double-setting
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            guard !showAddGestureSheet else {
                                print("🐛 Sheet already showing, skipping")
                                return
                            }
                            print("🐛 Setting showAddGestureSheet to true")
                            showAddGestureSheet = true
                        }
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
                    // Prevent multiple presentations and rapid tapping
                    let now = Date()
                    guard !showAddGestureSheet &&
                          !isSheetPresenting &&
                          now.timeIntervalSince(lastTapTime) > 0.5 else {
                        print("🐛 Add button tap blocked - showSheet: \(showAddGestureSheet), presenting: \(isSheetPresenting)")
                        return
                    }

                    print("🐛 Opening add gesture sheet")
                    lastTapTime = now
                    isSheetPresenting = true
                    currentGestureSwitch = nil

                    // Small delay to ensure state is stable and prevent double-setting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        guard !showAddGestureSheet else {
                            print("🐛 Add sheet already showing, skipping")
                            return
                        }
                        print("🐛 Setting showAddGestureSheet to true for add")
                        showAddGestureSheet = true
                    }
                }, label: {
                    Label(
                        String(
                            localized: "Add Facial Gesture",
                            comment: "Button label to add a new facial gesture switch"
                        ),
                        systemImage: "plus.circle.fill"
                    )
                })







                if facialGestureSwitches.isEmpty {
                    Button(action: {
                        addDefaultGestures()
                    }, label: {
                        Label(
                            String(
                                localized: "Add Default Gestures",
                                comment: "Button label to add default facial gesture switches"
                            ),
                            systemImage: "wand.and.stars"
                        )
                    })
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
        .sheet(isPresented: Binding(
            get: { showAddGestureSheet },
            set: { newValue in
                print("🐛 Sheet binding set to: \(newValue)")
                if !newValue && showAddGestureSheet {
                    // Only update if actually changing from true to false
                    showAddGestureSheet = false
                    currentGestureSwitch = nil
                    isSheetPresenting = false
                    print("🐛 Sheet dismissed via binding, state reset")
                }
            }
        ), onDismiss: {
            // Additional safety reset
            print("🐛 Sheet onDismiss called")
            DispatchQueue.main.async {
                currentGestureSwitch = nil
                isSheetPresenting = false
                showAddGestureSheet = false
            }
        }) {
            if let gestureSwitch = currentGestureSwitch {
                AddFacialGestureSheet(currentGestureSwitch: .constant(gestureSwitch))
            } else {
                AddFacialGestureSheet(currentGestureSwitch: .constant(nil))
            }
        }
        .onAppear {
            // Give database time to fully initialize
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isDatabaseReady = true
                print("🐛 Database marked as ready")
            }
        }
        .onChange(of: showAddGestureSheet) { _, newValue in
            print("🐛 showAddGestureSheet changed to: \(newValue)")
            if !newValue {
                // Sheet was dismissed, reset presenting state
                isSheetPresenting = false
            }
        }
        .onChange(of: showAddGestureSheet) { _, newValue in
            print("🐛 showAddGestureSheet changed to: \(newValue)")
            if !newValue {
                // Sheet was dismissed, reset presenting state
                isSheetPresenting = false
            }
        }
    }
    
    private func addDefaultGestures() {
        let defaultSwitches = FacialGestureSwitch.createDefaultSwitches()
        for gestureSwitch in defaultSwitches {
            modelContext.insert(gestureSwitch)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save default facial gesture switches: \(error)")
        }
    }
}

struct AddFacialGestureSheet: View {
    @Binding var currentGestureSwitch: FacialGestureSwitch?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            if let gestureSwitch = currentGestureSwitch {
                AddFacialGesture(currentGestureSwitch: .constant(gestureSwitch))
            } else {
                AddFacialGesture(currentGestureSwitch: $currentGestureSwitch)
            }
        }
    }
}

struct AddFacialGesture: View {
    @Environment(\.dismiss) var dismiss
    @Binding var currentGestureSwitch: FacialGestureSwitch?
    @State private var deleteAlert: Bool = false

    @Environment(\.modelContext) var modelContext
    @Query var facialGestureSwitches: [FacialGestureSwitch]

    @State private var selectedGesture: FacialGesture = .eyeBlinkLeft
    @State private var gestureName: String = ""

    var body: some View {
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
                    .pickerStyle(.navigationLink)

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
                            holdAction: unwrappedGestureSwitch.holdAction
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
                    .pickerStyle(.navigationLink)

                }, header: {
                    Text("New Gesture", comment: "Header for new gesture section")
                })

                // Preview section for new gesture
                if ARFaceTrackingConfiguration.isSupported {
                    Section(content: {
                        GesturePreviewSection(
                            gesture: selectedGesture,
                            threshold: selectedGesture.defaultThreshold,
                            holdDuration: 1.0, // Default hold duration
                            tapAction: .nextNode, // Default tap action
                            holdAction: .none // Default hold action
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
            }
        }
        .onChange(of: selectedGesture) { _, newGesture in
            if currentGestureSwitch == nil && gestureName.isEmpty {
                gestureName = newGesture.displayName
            }
        }
    }

    private func saveGesture() {
        if currentGestureSwitch == nil {
            // Create new gesture switch
            let newGestureSwitch = FacialGestureSwitch(
                name: gestureName,
                gesture: selectedGesture
            )
            modelContext.insert(newGestureSwitch)
            currentGestureSwitch = newGestureSwitch
        }

        do {
            try modelContext.save()
        } catch {
            print("Failed to save facial gesture switch: \(error)")
        }
    }
}
