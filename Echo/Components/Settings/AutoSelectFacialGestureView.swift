//
//  AutoSelectFacialGestureView.swift
//  Echo
//
//  Created by Will Wade on 08/07/2025.
//

import SwiftUI
import ARKit

struct AutoSelectFacialGestureView: View {
    @Binding var selectedGesture: FacialGesture
    @Environment(\.dismiss) private var dismiss

    @StateObject private var gestureDetector = FacialGestureDetector.shared
    @State private var countdownValue = 3
    @State private var isCountingDown = false
    @State private var isCapturing = false
    @State private var hasCompleted = false
    @State private var detectedGesture: FacialGesture?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var resultsTimer: Timer?
    
    private enum DetectionPhase {
        case ready
        case countdown
        case baseline
        case capture
        case analysis
        case results
        case complete
    }
    
    @State private var currentPhase: DetectionPhase = .ready
    
    var overlayText: String {
        switch currentPhase {
        case .ready:
            return "Position your face in the camera and tap Start"
        case .countdown:
            return "Get ready... \(countdownValue)"
        case .baseline:
            return "Stay neutral for baseline..."
        case .capture:
            return "Now make your gesture!"
        case .analysis:
            return "Analyzing..."
        case .results:
            return "Select the gesture you performed:"
        case .complete:
            if let gesture = detectedGesture {
                return "Selected: \(gesture.displayName)"
            } else {
                return "No gesture selected"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                cameraView
                topRightControls
                gestureRankingOverlay
            }
            .navigationTitle("Auto Select Gesture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        gestureDetector.stopAutoDetectionMode()
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .onAppear {
                // Signal that auto-select is active
                FacialGestureDetector.isAutoSelectActive = true
                print("🎯 Auto-select view appeared - set isAutoSelectActive = true")

                // Start camera preview immediately when view appears
                if gestureDetector.isSupported {
                    gestureDetector.startAutoDetectionMode { detectedGesture in
                        // This callback will be used later when detection actually runs
                        DispatchQueue.main.async {
                            self.detectedGesture = detectedGesture
                            self.currentPhase = .complete
                        }
                    }
                }
            }
            .onDisappear {
                // Clean up timers
                resultsTimer?.invalidate()
                resultsTimer = nil

                // Stop auto-detection
                gestureDetector.stopAutoDetectionMode()

                // Signal that auto-select is no longer active
                FacialGestureDetector.isAutoSelectActive = false
                print("🎯 Auto-select view disappeared - set isAutoSelectActive = false")
            }
            .onReceive(gestureDetector.$isActive) { isActive in
                // Reset to ready phase if session becomes inactive during detection
                if !isActive && currentPhase != .ready && currentPhase != .complete {
                    currentPhase = .ready
                    countdownValue = 3
                }
            }
        }
    }

    // MARK: - View Components

    private var cameraView: some View {
        FacialGestureAutoDetectCameraView(
            gestureDetector: gestureDetector,
            overlayText: overlayText,
            detectedGestures: gestureDetector.detectedGestureNames
        )
    }

    private var topRightControls: some View {
        VStack {
            HStack {
                Spacer()

                if currentPhase == .ready {
                    readyPhaseControls
                } else if currentPhase == .complete {
                    completePhaseControls
                }
            }
            .padding(.top, 20)
            .padding(.trailing, 20)

            Spacer()
        }
    }

    private var readyPhaseControls: some View {
        let isButtonEnabled = gestureDetector.isSupported && gestureDetector.isActive
        print("🎯 AutoSelect: Button enabled = \(isButtonEnabled) (supported: \(gestureDetector.isSupported), active: \(gestureDetector.isActive))")

        return VStack(spacing: 12) {
            Button(action: startDetection) {
                Label("Start", systemImage: "play.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(!isButtonEnabled)

            if !gestureDetector.isSupported {
                Text("Not supported")
                    .font(.caption2)
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
            } else if !gestureDetector.isActive {
                Text("Camera starting...")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(4)
            }
        }
    }

    private var completePhaseControls: some View {
        VStack(spacing: 8) {
            Button(action: resetDetection) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
            }
        }
    }

    @ViewBuilder
    private var gestureRankingOverlay: some View {
        if currentPhase == .results {
            gestureRankingView
        }
    }

    private var gestureRankingView: some View {
        VStack(spacing: 16) {
            Text("Select the gesture you performed:")
                .font(.headline)
                .foregroundColor(.white)
                .shadow(color: .black, radius: 2, x: 1, y: 1)

            gestureList

            Button(action: resetDetection) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.orange.opacity(0.8))
                    .cornerRadius(12)
            }
        }
        .padding()
        .background(Color.black.opacity(0.7))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }

    private var gestureList: some View {
        VStack(spacing: 8) {
            ForEach(Array(gestureDetector.rankedGestures.enumerated()), id: \.offset) { index, gestureData in
                gestureButton(for: gestureData, isTop: index == 0)
            }
        }
        .padding(.horizontal, 20)
    }

    private func gestureButton(for gestureData: (gesture: FacialGesture, percentage: Float), isTop: Bool) -> some View {
        Button(action: {
            selectGesture(gestureData.gesture)
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(gestureData.gesture.displayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(gestureData.gesture.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
                Text("\(Int(gestureData.percentage * 100))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isTop ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
    }

    // MARK: - Methods

    private func startDetection() {
        print("🎯 AutoSelect: startDetection() called")
        print("🎯 AutoSelect: gestureDetector.isSupported = \(gestureDetector.isSupported)")
        print("🎯 AutoSelect: gestureDetector.isActive = \(gestureDetector.isActive)")
        print("🎯 AutoSelect: currentPhase = \(currentPhase)")

        guard gestureDetector.isSupported else {
            print("🎯 AutoSelect: Face tracking not supported")
            showError(message: "Face tracking is not supported on this device")
            return
        }

        guard gestureDetector.isActive else {
            print("🎯 AutoSelect: Camera not ready")
            showError(message: "Camera is not ready. Please wait for the camera to start.")
            return
        }

        print("🎯 AutoSelect: Starting countdown")
        currentPhase = .countdown
        countdownValue = 3

        // Camera is already running, just start countdown
        startCountdown()
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdownValue > 1 {
                countdownValue -= 1
            } else {
                timer.invalidate()
                captureBaseline()
            }
        }
    }
    
    private func captureBaseline() {
        currentPhase = .baseline
        
        // Wait a moment for user to be neutral, then capture baseline
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            gestureDetector.captureBaseline()
            startGestureCapture()
        }
    }
    
    private func startGestureCapture() {
        currentPhase = .capture
        
        // Capture for 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            analyzeResults()
        }
    }
    
    private func analyzeResults() {
        currentPhase = .analysis

        // Analyze the captured data
        _ = gestureDetector.analyzeGestureChanges()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.gestureDetector.rankedGestures.isEmpty {
                self.currentPhase = .results
                // Start a timer to automatically reset if no selection is made
                self.startResultsTimer()
            } else {
                self.detectedGesture = nil
                self.currentPhase = .complete
            }
        }
    }
    
    private func selectGesture(_ gesture: FacialGesture) {
        // Cancel the results timer since user made a selection
        resultsTimer?.invalidate()
        resultsTimer = nil

        detectedGesture = gesture
        selectedGesture = gesture
        currentPhase = .complete

        // Auto-dismiss after a brief moment to show confirmation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.gestureDetector.stopAutoDetectionMode()

            // Dismiss twice to go back to the main form (same pattern as manual selection)
            self.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.dismiss()
            }
        }
    }

    private func selectDetectedGesture() {
        guard let gesture = detectedGesture else { return }
        selectGesture(gesture)
    }
    
    private func startResultsTimer() {
        // Cancel any existing timer
        resultsTimer?.invalidate()

        // Start a 10-second timer to automatically reset if no selection is made
        resultsTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { _ in
            DispatchQueue.main.async {
                print("🎯 Results timer expired - resetting detection")
                self.resetDetection()
            }
        }
    }

    private func resetDetection() {
        // Cancel the results timer
        resultsTimer?.invalidate()
        resultsTimer = nil

        currentPhase = .ready
        detectedGesture = nil
        countdownValue = 3

        // Restart the camera for the next attempt
        if gestureDetector.isSupported {
            gestureDetector.startAutoDetectionMode { detectedGesture in
                DispatchQueue.main.async {
                    self.detectedGesture = detectedGesture
                    self.currentPhase = .complete
                }
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    AutoSelectFacialGestureView(selectedGesture: .constant(.eyeBlinkLeft))
}
