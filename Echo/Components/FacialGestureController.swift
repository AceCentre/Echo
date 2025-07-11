//
//  FacialGestureController.swift
//  Echo
//
//  Created by Will Wade on 04/07/2025.
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
    @Environment(\.scenePhase) var scenePhase

    @Query var facialGestureSwitches: [FacialGestureSwitch]

    @State private var gestureDetector = FacialGestureDetector()
    @State private var isInitialized = false
    
    var body: some View {
        // This view doesn't render anything visible
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                print("🎯 FacialGestureController.onAppear called")
                setupGestureDetection()

                // Listen for auto-select state changes
                NotificationCenter.default.addObserver(
                    forName: .autoSelectActiveChanged,
                    object: nil,
                    queue: .main
                ) { notification in
                    if let isActive = notification.userInfo?["isActive"] as? Bool {
                        self.handleAutoSelectStateChange(isActive)
                    }
                }

                // Listen for preview mode state changes
                NotificationCenter.default.addObserver(
                    forName: .previewModeActiveChanged,
                    object: nil,
                    queue: .main
                ) { notification in
                    if let isActive = notification.object as? Bool {
                        self.handlePreviewModeStateChange(isActive)
                    }
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                print("🎯 FacialGestureController.scenePhase changed to: \(newPhase)")
                handleScenePhaseChange(newPhase)
            }
            .onChange(of: facialGestureSwitches) { _, _ in
                print("🎯 Facial gesture switches changed - count: \(facialGestureSwitches.count)")
                // Reconfigure when switches change
                if gestureDetector.isSupported {
                    setupGestureDetection()
                }
            }

    }
    
    private func setupGestureDetection() {
        print("🎯 FacialGestureController.setupGestureDetection() called")
        print("🎯 Gesture detector supported: \(gestureDetector.isSupported)")
        print("🎯 Total facial gesture switches: \(facialGestureSwitches.count)")

        guard gestureDetector.isSupported else {
            print("🎯 Gesture detection not supported - exiting")
            return
        }

        // Don't start if auto-select is active
        if FacialGestureDetector.isAutoSelectActive {
            print("🎯 Auto-select is active, skipping main gesture detection setup")
            return
        }

        // Don't start if preview mode is active
        if gestureDetector.isPreviewMode {
            print("🎯 Preview mode is active, skipping main gesture detection setup")
            return
        }

        // Stop any existing detection
        print("🎯 Stopping any existing detection")
        gestureDetector.stopDetection()

        // Configure gestures for enabled switches
        var configuredGestures = 0
        for gestureSwitch in facialGestureSwitches where gestureSwitch.isEnabled {
            print("🎯 Processing switch: \(gestureSwitch.name), enabled: \(gestureSwitch.isEnabled)")
            if let gesture = gestureSwitch.gesture {
                print("🎯 Configuring gesture: \(gesture.displayName), threshold: \(gestureSwitch.threshold)")
                gestureDetector.configureGesture(
                    gesture,
                    threshold: gestureSwitch.threshold,
                    holdDuration: gestureSwitch.holdDuration
                )
                configuredGestures += 1
            } else {
                print("🎯 Switch has no gesture: \(gestureSwitch.name)")
            }
        }

        print("🎯 Configured gestures: \(configuredGestures)")
        if configuredGestures > 0 {
            // Start detection with callback
            print("🎯 Starting gesture detection with \(configuredGestures) gestures")
            gestureDetector.startDetection { [weak mainCommunicationPageState] gesture, isHoldAction in
                print("🎯 Gesture detected: \(gesture.displayName), isHold: \(isHoldAction)")
                handleGestureDetected(gesture: gesture, isHoldAction: isHoldAction, mainCommunicationPageState: mainCommunicationPageState)
            }
            print("🎯 Gesture detection started - isActive: \(gestureDetector.isActive)")
        } else {
            print("🎯 No gestures configured - not starting detection")
        }

        isInitialized = true
        print("🎯 FacialGestureController initialization complete")
    }

    private func handleAutoSelectStateChange(_ isActive: Bool) {
        print("🎯 Auto-select state changed to: \(isActive)")
        if isActive {
            // Pause main gesture detection when auto-select is active
            print("🎯 Pausing main gesture detection for auto-select")
            gestureDetector.stopDetection()
        } else {
            // Resume main gesture detection when auto-select is done
            print("🎯 Resuming main gesture detection after auto-select")
            if gestureDetector.isSupported && !facialGestureSwitches.filter({ $0.isEnabled && $0.gesture != nil }).isEmpty {
                setupGestureDetection()
            }
        }
    }

    private func handlePreviewModeStateChange(_ isActive: Bool) {
        print("🎯 Preview mode state changed to: \(isActive)")
        if isActive {
            // Pause main gesture detection when preview mode is active
            print("🎯 Pausing main gesture detection for preview mode")
            gestureDetector.stopDetection()
        } else {
            // Resume main gesture detection when preview mode is done
            print("🎯 Resuming main gesture detection after preview mode")
            if gestureDetector.isSupported && !facialGestureSwitches.filter({ $0.isEnabled && $0.gesture != nil }).isEmpty {
                setupGestureDetection()
            }
        }
    }

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("🎯 App became active - restarting gesture detection if needed")
            // Only restart if we have configured gestures and detector is supported
            if gestureDetector.isSupported && !facialGestureSwitches.filter({ $0.isEnabled && $0.gesture != nil }).isEmpty {
                setupGestureDetection()
            }
        case .inactive:
            print("🎯 App became inactive - keeping gesture detection running")
            // Don't stop detection for inactive (e.g., when opening Control Center)
        case .background:
            print("🎯 App went to background - stopping gesture detection")
            gestureDetector.stopDetection()
        @unknown default:
            break
        }
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
