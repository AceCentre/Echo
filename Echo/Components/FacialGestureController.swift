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
    
    @Query var facialGestureSwitches: [FacialGestureSwitch]
    
    @StateObject private var gestureDetector = FacialGestureDetector()
    @State private var isInitialized = false
    
    var body: some View {
        // This view doesn't render anything visible
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
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
        guard settings.enableSwitchControl else { return }
        guard gestureDetector.isSupported else { return }
        
        // Stop any existing detection
        gestureDetector.stopDetection()
        
        // Configure gestures for enabled switches
        for gestureSwitch in facialGestureSwitches where gestureSwitch.isEnabled {
            if let gesture = gestureSwitch.gesture {
                gestureDetector.configureGesture(
                    gesture,
                    threshold: gestureSwitch.threshold,
                    holdDuration: gestureSwitch.holdDuration
                )
            }
        }
        
        // Start detection with callback
        gestureDetector.startDetection { [weak mainCommunicationPageState] gesture, isHoldAction in
            handleGestureDetected(gesture: gesture, isHoldAction: isHoldAction, mainCommunicationPageState: mainCommunicationPageState)
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
