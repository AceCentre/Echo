//
//  FacialGestureController.swift
//  Echo
//
//  Created by Augment Agent on 04/07/2025.
//

import SwiftUI
import SwiftData

/*
 FacialGestureController
 
 This component integrates facial gesture detection with Echo's switch input system.
 It works similarly to KeyPressController but uses facial gestures instead of keyboard input.
 
 For every registered facial gesture switch, it monitors facial movements and triggers
 the appropriate switch actions (tap or hold) based on gesture detection.
 
 The component doesn't visually display anything - it's purely functional.
 */
struct FacialGestureController: View {
    @ObservedObject var mainCommunicationPageState: MainCommunicationPageState
    @Environment(Settings.self) var settings: Settings
    @Environment(\.modelContext) var modelContext

    @Query var facialGestureSwitches: [FacialGestureSwitch]

    @StateObject private var gestureDetector = FacialGestureDetector()
    @State private var isInitialized = false
    
    var body: some View {
        // This view doesn't render anything visible
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                print("🎭 FacialGestureController: onAppear called")
                setupGestureDetection()
            }
            .onDisappear {
                gestureDetector.stopDetection()
            }
            .onChange(of: settings.enableSwitchControl) { _, newValue in
                if newValue {
                    setupGestureDetection()
                } else {
                    gestureDetector.stopDetection()
                }
            }
            .onChange(of: facialGestureSwitches) { _, _ in
                // Reconfigure when switches change
                if settings.enableSwitchControl && gestureDetector.isSupported {
                    setupGestureDetection()
                }
            }
    }
    
    private func setupGestureDetection() {
        print("🎭 FacialGestureController: setupGestureDetection called")
        print("🎭 FacialGestureController: enableSwitchControl = \(settings.enableSwitchControl)")
        print("🎭 FacialGestureController: isSupported = \(gestureDetector.isSupported)")
        print("🎭 FacialGestureController: facialGestureSwitches count = \(facialGestureSwitches.count)")

        // Debug: Print all facial gesture switches
        for (index, gestureSwitch) in facialGestureSwitches.enumerated() {
            print("🎭 FacialGestureController: Switch \(index): \(gestureSwitch.name), enabled: \(gestureSwitch.isEnabled), gesture: \(gestureSwitch.gesture?.displayName ?? "nil")")
        }

        // Double-check with manual database query
        do {
            let descriptor = FetchDescriptor<FacialGestureSwitch>()
            let allSwitches = try modelContext.fetch(descriptor)
            print("🎭 FacialGestureController: Manual query found \(allSwitches.count) switches in database")
            for (index, gestureSwitch) in allSwitches.enumerated() {
                print("🎭 FacialGestureController: DB Switch \(index): \(gestureSwitch.name), enabled: \(gestureSwitch.isEnabled)")
            }
        } catch {
            print("🎭 FacialGestureController: Error querying database: \(error)")
        }

        guard settings.enableSwitchControl else {
            print("🎭 FacialGestureController: Switch control disabled, returning")
            return
        }
        guard gestureDetector.isSupported else {
            print("🎭 FacialGestureController: Face tracking not supported, returning")
            return
        }

        // Stop any existing detection
        gestureDetector.stopDetection()

        // Configure gestures for enabled switches
        var configuredGestures = 0
        for gestureSwitch in facialGestureSwitches where gestureSwitch.isEnabled {
            if let gesture = gestureSwitch.gesture {
                print("🎭 FacialGestureController: Configuring gesture \(gesture.displayName)")
                gestureDetector.configureGesture(
                    gesture,
                    threshold: gestureSwitch.threshold,
                    holdDuration: gestureSwitch.holdDuration
                )
                configuredGestures += 1
            }
        }

        print("🎭 FacialGestureController: Configured \(configuredGestures) gestures")

        if configuredGestures > 0 {
            // Start detection with callback
            print("🎭 FacialGestureController: Starting gesture detection...")
            gestureDetector.startDetection { [weak mainCommunicationPageState] gesture, isHoldAction in
                print("🎭 FacialGestureController: Gesture detected: \(gesture.displayName), isHold: \(isHoldAction)")
                handleGestureDetected(gesture: gesture, isHoldAction: isHoldAction, mainCommunicationPageState: mainCommunicationPageState)
            }
        } else {
            print("🎭 FacialGestureController: No gestures configured, not starting detection")
        }

        isInitialized = true
    }
    
    private func handleGestureDetected(gesture: FacialGesture, isHoldAction: Bool, mainCommunicationPageState: MainCommunicationPageState?) {
        guard let mainState = mainCommunicationPageState else { return }

        // Find the corresponding switch for this gesture
        guard let gestureSwitch = facialGestureSwitches.first(where: { $0.gesture == gesture && $0.isEnabled }) else {
            return
        }

        // Determine which action to trigger
        let action = isHoldAction ? gestureSwitch.holdAction : gestureSwitch.tapAction

        // Execute the switch action
        executeSwitchAction(action, on: mainState)
    }
    
    private func executeSwitchAction(_ action: SwitchAction, on mainState: MainCommunicationPageState) {
        // Use the existing doAction method that handles all switch actions
        mainState.doAction(action: action)
    }
}

// MARK: - Preview
#Preview {
    FacialGestureController(
        mainCommunicationPageState: MainCommunicationPageState()
    )
    .modelContainer(for: [FacialGestureSwitch.self])
}
