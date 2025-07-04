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

struct FacialGestureSwitchSection: View {
    @State var tapAction: SwitchAction
    @State var holdAction: SwitchAction
    @State var threshold: Float
    @State var holdDuration: Double
    @State var isEnabled: Bool
    @State var durationType: GestureDurationType

    var gestureSwitch: FacialGestureSwitch

    init(gestureSwitch: FacialGestureSwitch) {
        self.gestureSwitch = gestureSwitch
        self._tapAction = State(initialValue: gestureSwitch.tapAction)
        self._holdAction = State(initialValue: gestureSwitch.holdAction)
        self._threshold = State(initialValue: gestureSwitch.threshold)
        self._holdDuration = State(initialValue: gestureSwitch.holdDuration)
        self._isEnabled = State(initialValue: gestureSwitch.isEnabled)
        self._durationType = State(initialValue: gestureSwitch.durationType)
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

                // Duration type picker
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(
                        localized: "Duration Type",
                        comment: "Label for duration type picker"
                    ))
                    .font(.caption)
                    .foregroundColor(.secondary)

                    Picker("Duration Type", selection: $durationType) {
                        ForEach(GestureDurationType.allCases) { type in
                            VStack(alignment: .leading) {
                                Text(type.displayName)
                                Text(type.description)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Hold action picker (only for hold duration types)
                if durationType != .tap {
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
                }
                
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

                // Gesture Preview
                if let gesture = gestureSwitch.gesture, ARFaceTrackingConfiguration.isSupported {
                    GesturePreviewSection(gesture: gesture, threshold: threshold)
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
        .onChange(of: durationType) { _, _ in
            gestureSwitch.durationType = durationType
        }
    }
}

struct GlobalDurationSettings: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Settings.self) var settings: Settings

    var body: some View {
        @Bindable var settingsBindable = settings

        NavigationStack {
            Form {
                Section(content: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Short Hold Duration")
                            Spacer()
                            Text("\(String(format: "%.1f", settings.facialGestureShortHoldDuration))s")
                                .foregroundColor(.secondary)
                        }

                        Slider(
                            value: $settingsBindable.facialGestureShortHoldDuration,
                            in: 0.3...2.0,
                            step: 0.1
                        )
                        .tint(.blue)

                        Text("Duration for short hold gestures")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Long Hold Duration")
                            Spacer()
                            Text("\(String(format: "%.1f", settings.facialGestureLongHoldDuration))s")
                                .foregroundColor(.secondary)
                        }

                        Slider(
                            value: $settingsBindable.facialGestureLongHoldDuration,
                            in: 1.0...5.0,
                            step: 0.1
                        )
                        .tint(.blue)

                        Text("Duration for long hold gestures")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }, header: {
                    Text("Duration Settings", comment: "Header for duration settings section")
                }, footer: {
                    Text("These settings apply to all facial gestures configured with short hold or long hold duration types. Individual gestures can still have their own sensitivity thresholds.", comment: "Footer explaining global duration settings")
                })

                Section(content: {
                    Button(action: {
                        resetToDefaults()
                    }) {
                        Text("Reset to Defaults", comment: "Button to reset settings to defaults")
                            .foregroundColor(.red)
                    }
                }, header: {
                    Text("Reset", comment: "Header for reset section")
                })
            }
            .navigationTitle("Global Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func resetToDefaults() {
        settings.facialGestureShortHoldDuration = 0.8
        settings.facialGestureLongHoldDuration = 2.0
    }
}

struct GesturePreviewSection: View {
    let gesture: FacialGesture
    let threshold: Float
    @StateObject private var detector = FacialGestureDetector()
    @State private var isActive = false

    var gestureValue: Float {
        detector.previewGestureValues[gesture] ?? 0.0
    }

    var isGestureDetected: Bool {
        gestureValue >= threshold
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
                            Text("✓ Detected")
                                .font(.caption2)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                    }

                    // Simple progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)

                            Rectangle()
                                .fill(isGestureDetected ? Color.green : Color.blue)
                                .frame(width: CGFloat(gestureValue) * geometry.size.width, height: 4)
                                .animation(.easeInOut(duration: 0.1), value: gestureValue)
                        }
                    }
                    .frame(height: 4)
                }
                .padding(.vertical, 4)
            }
        }
        .onDisappear {
            stopPreview()
        }
    }

    private func startPreview() {
        detector.startPreviewMode(for: [gesture])
        isActive = true
    }

    private func stopPreview() {
        detector.stopPreviewMode()
        isActive = false
    }
}

struct FacialGestureSection: View {
    @Environment(\.modelContext) var modelContext
    @Environment(Settings.self) var settings: Settings
    @Query var facialGestureSwitches: [FacialGestureSwitch]

    @State private var currentGestureSwitch: FacialGestureSwitch?
    @State private var showAddGestureSheet = false
    @State private var showGlobalSettings = false
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
                ForEach(facialGestureSwitches, id: \.gestureRaw) { gestureSwitch in
                    Button(action: {
                        currentGestureSwitch = gestureSwitch
                        showAddGestureSheet = true
                    }, label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(gestureSwitch.displayName)
                                    .foregroundColor(.primary)

                                if let gesture = gestureSwitch.gesture {
                                    Text(gesture.description)
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
                    showAddGestureSheet = true
                }, label: {
                    Label(
                        String(
                            localized: "Add Facial Gesture",
                            comment: "Button label to add a new facial gesture switch"
                        ),
                        systemImage: "plus.circle.fill"
                    )
                })

                Button(action: {
                    showGlobalSettings = true
                }, label: {
                    Label(
                        String(
                            localized: "Global Settings",
                            comment: "Button label for global facial gesture settings"
                        ),
                        systemImage: "gearshape.fill"
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
        .sheet(isPresented: $showAddGestureSheet) {
            AddFacialGestureSheet(currentGestureSwitch: $currentGestureSwitch)
        }
        .sheet(isPresented: $showGlobalSettings) {
            GlobalDurationSettings()
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
