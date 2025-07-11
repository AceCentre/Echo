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

    @StateObject private var gestureDetector = FacialGestureDetector.shared
    @State private var isInitialized = false
    
    var body: some View {
        // This view doesn't render anything visible
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
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
                handleScenePhaseChange(newPhase)
            }
            .onChange(of: facialGestureSwitches) { _, _ in
                // Only reconfigure when switches change if we're in navigation mode or inactive
                // Don't interfere with preview or auto-select modes
                if gestureDetector.isSupported &&
                   (gestureDetector.currentMode == .navigation || gestureDetector.currentMode == .inactive) {
                    setupGestureDetection()
                }
            }

    }
    
    private func setupGestureDetection() {
        guard gestureDetector.isSupported else {
            return
        }

        // Don't interfere with other modes
        if FacialGestureDetector.isAutoSelectActive {
            return
        }

        if gestureDetector.isPreviewMode {
            return
        }

        // Only proceed if we're not already in navigation mode
        if gestureDetector.currentMode == .navigation {
            return
        }

        // Only stop detection if we're not in a critical mode
        if gestureDetector.currentMode != .preview && gestureDetector.currentMode != .autoSelect {
            gestureDetector.stopDetection()
        }

        // Configure gestures for enabled switches
        var configuredGestures = 0
        for gestureSwitch in facialGestureSwitches where gestureSwitch.isEnabled {
            if let gesture = gestureSwitch.gesture {
                gestureDetector.configureGesture(
                    gesture,
                    threshold: gestureSwitch.threshold,
                    holdDuration: gestureSwitch.holdDuration
                )
                configuredGestures += 1
            }
        }

        if configuredGestures > 0 {
            // Start detection with callback
            gestureDetector.startDetection { [weak mainCommunicationPageState] gesture, isHoldAction in
                handleGestureDetected(gesture: gesture, isHoldAction: isHoldAction, mainCommunicationPageState: mainCommunicationPageState)
            }
        }

        isInitialized = true
    }

    private func handleAutoSelectStateChange(_ isActive: Bool) {
        if isActive {
            // Pause main gesture detection when auto-select is active
            // Only stop if we're currently in navigation mode
            if gestureDetector.currentMode == .navigation {
                gestureDetector.stopDetection()
            }
        } else {
            // Resume main gesture detection when auto-select is done
            // Only resume if we're not in another active mode
            if gestureDetector.isSupported &&
               !facialGestureSwitches.filter({ $0.isEnabled && $0.gesture != nil }).isEmpty &&
               gestureDetector.currentMode == .inactive {
                setupGestureDetection()
            }
        }
    }

    private func handlePreviewModeStateChange(_ isActive: Bool) {
        if isActive {
            // Pause main gesture detection when preview mode is active
            // Only stop if we're currently in navigation mode
            if gestureDetector.currentMode == .navigation {
                gestureDetector.stopDetection()
            }
        } else {
            // Resume main gesture detection when preview mode is done
            // Only resume if we're not in another active mode
            if gestureDetector.isSupported &&
               !facialGestureSwitches.filter({ $0.isEnabled && $0.gesture != nil }).isEmpty &&
               gestureDetector.currentMode == .inactive {
                setupGestureDetection()
            }
        }
    }

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            // Only restart if we have configured gestures and detector is supported
            // Don't interfere with preview or auto-select modes
            if gestureDetector.isSupported &&
               !facialGestureSwitches.filter({ $0.isEnabled && $0.gesture != nil }).isEmpty &&
               (gestureDetector.currentMode == .navigation || gestureDetector.currentMode == .inactive) {
                setupGestureDetection()
            }
        case .inactive:
            // Don't stop detection for inactive (e.g., when opening Control Center)
            break
        case .background:
            // Only stop if we're in navigation mode - don't interfere with other modes
            if gestureDetector.currentMode == .navigation {
                gestureDetector.stopDetection()
            }
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
