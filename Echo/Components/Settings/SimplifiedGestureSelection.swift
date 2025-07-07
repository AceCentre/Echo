//
//  SimplifiedGestureSelection.swift
//  Echo
//
//  Created by Augment Agent on 04/07/2025.
//

import SwiftUI
import SwiftData
import ARKit

struct SimplifiedGestureSelection: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(Settings.self) var settings: Settings
    @Query var facialGestureSwitches: [FacialGestureSwitch]
    
    @State private var selectedGesture: FacialGesture = .eyeBlinkLeft
    @State private var tapAction: SwitchAction = .nextNode
    @State private var holdAction: SwitchAction = .none
    @State private var threshold: Float = 0.8
    @State private var holdDuration: Double = 1.0
    @State private var showPreview = false
    
    // Preview state
    @StateObject private var previewDetector = FacialGestureDetector()
    @State private var previewGestureValue: Float = 0.0
    @State private var isPreviewActive = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Gesture Selection") {
                    Picker("Gesture Type", selection: $selectedGesture) {
                        ForEach(FacialGesture.commonGestures) { gesture in
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hold Duration")
                            Spacer()
                            Text("\(String(format: "%.1f", holdDuration))s")
                                .foregroundColor(.secondary)
                        }

                        Slider(value: $holdDuration, in: 0.5...3.0, step: 0.1)
                            .tint(.blue)

                        Text("Duration to trigger hold action")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Actions") {
                    ActionPicker(
                        label: "Tap Action",
                        actions: SwitchAction.tapCases,
                        actionChange: { newAction in
                            tapAction = newAction
                        },
                        actionState: tapAction
                    )
                    
                    ActionPicker(
                        label: "Hold Action",
                        actions: SwitchAction.holdCases,
                        actionChange: { newAction in
                            holdAction = newAction
                        },
                        actionState: holdAction
                    )
                }
                
                Section("Sensitivity") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Threshold")
                            Spacer()
                            Text("\(Int(threshold * 100))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $threshold, in: 0.1...1.0, step: 0.05)
                            .tint(.blue)
                        
                        Text("Lower values make the gesture more sensitive")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if ARFaceTrackingConfiguration.isSupported {
                    Section("Preview") {
                        Button(action: {
                            showPreview.toggle()
                        }) {
                            Label(
                                showPreview ? "Stop Preview" : "Test Gesture",
                                systemImage: showPreview ? "stop.circle" : "play.circle"
                            )
                        }
                        
                        if showPreview {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Gesture Strength:")
                                    Spacer()
                                    Text("\(Int(previewGestureValue * 100))%")
                                        .foregroundColor(previewGestureValue >= threshold ? .green : .secondary)
                                }
                                
                                ProgressView(value: previewGestureValue, total: 1.0)
                                    .tint(previewGestureValue >= threshold ? .green : .blue)
                                
                                if previewGestureValue >= threshold {
                                    Text("✓ Gesture detected!")
                                        .foregroundColor(.green)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Gesture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGesture()
                        dismiss()
                    }
                    .disabled(gestureAlreadyExists)
                }
            }
            .onChange(of: selectedGesture) { _, newGesture in
                threshold = newGesture.defaultThreshold
            }
            .onChange(of: showPreview) { _, isShowing in
                if isShowing {
                    startPreview()
                } else {
                    stopPreview()
                }
            }
            .onDisappear {
                stopPreview()
            }
        }
    }
    
    private var gestureAlreadyExists: Bool {
        facialGestureSwitches.contains { gestureSwitch in
            gestureSwitch.gesture == selectedGesture
        }
    }
    
    private func saveGesture() {
        let newGestureSwitch = FacialGestureSwitch(
            name: selectedGesture.displayName,
            gesture: selectedGesture,
            threshold: threshold,
            tapAction: tapAction,
            holdAction: holdAction,
            isEnabled: true,
            holdDuration: holdDuration
        )

        modelContext.insert(newGestureSwitch)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save facial gesture switch: \(error)")
        }
    }
    
    private func startPreview() {
        guard previewDetector.isSupported else { return }
        
        previewDetector.configureGesture(selectedGesture, threshold: 0.0) // Use 0.0 to get raw values
        previewDetector.startDetection { gesture, _ in
            // We don't need the gesture detection callback for preview
        }
        
        // Start monitoring gesture values
        isPreviewActive = true
        monitorGestureValues()
    }
    
    private func stopPreview() {
        previewDetector.stopDetection()
        isPreviewActive = false
        previewGestureValue = 0.0
    }
    
    private func monitorGestureValues() {
        // This would need to be implemented with a timer or other mechanism
        // to continuously read gesture values from the detector
        // For now, this is a placeholder for the preview functionality
    }
}

#Preview {
    SimplifiedGestureSelection()
        .modelContainer(for: [FacialGestureSwitch.self])
}
