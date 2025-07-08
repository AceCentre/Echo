//
//  FacialGestureDetector.swift
//  Echo
//
//  Created by Will Wade on 04/07/2025.
//

import Foundation
import ARKit
import SwiftUI
import AVFoundation

class FacialGestureDetector: NSObject, ObservableObject, ARSessionDelegate {
    @Published var isActive: Bool = false
    @Published var isSupported: Bool = false
    @Published var errorMessage: String?
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined

    // Preview mode properties
    @Published var isPreviewMode: Bool = false
    @Published var previewGestureValues: [FacialGesture: Float] = [:]

    // Auto-detection mode properties
    @Published var isAutoDetectionMode: Bool = false
    @Published var autoDetectionBaseline: [FacialGesture: Float] = [:]
    @Published var autoDetectionCurrentValues: [FacialGesture: Float] = [:]
    @Published var autoDetectionResults: [FacialGesture: Float] = [:]
    @Published var detectedGestureNames: [String] = []
    @Published var rankedGestures: [(gesture: FacialGesture, percentage: Float)] = []

    var session = ARSession()
    private var gestureStates: [FacialGesture: GestureState] = [:]
    private var onGestureDetected: ((FacialGesture, Bool) -> Void)?
    private var previewGestures: Set<FacialGesture> = []
    private var onAutoDetectionComplete: ((FacialGesture?) -> Void)?
    private var lastUpdateTime: Date = Date()
    private var lastFaceAnchorTime: Date = Date()
    private var sessionHealthTimer: Timer?

    // Gesture responsiveness monitoring
    private var gestureValueHistory: [FacialGesture: [Float]] = [:]
    private var lastGestureVarianceCheck: Date = Date()

    // Preview corruption detection
    private var lastPreviewUpdateTime: Date = Date()
    private var previewCorruptionCheckTimer: Timer?
    
    private struct GestureState {
        var isActive: Bool = false
        var startTime: Date?
        var threshold: Float
        var holdDuration: Double
        
        init(threshold: Float, holdDuration: Double = 1.0) {
            self.threshold = threshold
            self.holdDuration = holdDuration
        }
    }
    
    override init() {
        super.init()
        setupARKit()
        checkCameraPermission()
    }
    
    deinit {
        stopDetection()
    }
    
    // MARK: - Public Methods
    
    func startDetection(onGestureDetected: @escaping (FacialGesture, Bool) -> Void) {
        guard isSupported else {
            errorMessage = String(localized: "Face tracking is not supported on this device", comment: "Error message for unsupported device")
            return
        }

        // Store the callback for later use
        self.onGestureDetected = onGestureDetected

        // Check camera permission before starting
        checkCameraPermission()

        if cameraPermissionStatus == .authorized {
            // Permission already granted, start immediately
            startARSession()
        } else if cameraPermissionStatus == .denied {
            errorMessage = String(localized: "Camera access denied. Please enable camera access in Settings to use facial gestures.", comment: "Error message for denied camera permission")
        } else {
            // Permission not determined, request it
            errorMessage = String(localized: "Camera access required for facial gesture detection.", comment: "Error message for camera permission needed")
            requestCameraPermission { [weak self] granted in
                if granted {
                    self?.startARSession()
                }
            }
        }
    }

    private func startARSession() {
        print("startARSession called")
        let configuration = ARFaceTrackingConfiguration()
        print("Running AR session with configuration")
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        DispatchQueue.main.async {
            print("Setting isActive to true on main queue")
            self.isActive = true
            self.errorMessage = nil
            print("isActive is now: \(self.isActive)")

            // Start session health monitoring
            self.startSessionHealthMonitoring()
        }
    }

    private func startSessionHealthMonitoring() {
        // Stop any existing timer
        sessionHealthTimer?.invalidate()

        // Start a timer to check if we're still receiving face anchors
        sessionHealthTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.checkSessionHealth()
        }

        // Start preview corruption monitoring if in preview mode
        if isPreviewMode {
            startPreviewCorruptionMonitoring()
        }
    }

    private func checkSessionHealth() {
        let timeSinceLastFaceAnchor = Date().timeIntervalSince(lastFaceAnchorTime)

        // If we haven't received a face anchor in 3 seconds and we should be active, restart the session
        if timeSinceLastFaceAnchor > 3.0 && isActive && (isPreviewMode || isAutoDetectionMode || onGestureDetected != nil) {
            print("⚠️ ARKit session appears stuck - no face anchors for \(timeSinceLastFaceAnchor)s. Restarting...")
            DispatchQueue.main.async {
                self.restartARSession()
            }
            return
        }

        // Check for unresponsive gesture values (stuck at low levels)
        checkGestureResponsiveness()
    }

    private func checkGestureResponsiveness() {
        let currentTime = Date()
        let timeSinceLastCheck = currentTime.timeIntervalSince(lastGestureVarianceCheck)

        // Only check every 10 seconds to allow enough data to accumulate
        guard timeSinceLastCheck >= 10.0 else { return }
        lastGestureVarianceCheck = currentTime

        // Check if we have enough history and if gesture values are stuck
        for (gesture, history) in gestureValueHistory {
            guard history.count >= 20 else { continue } // Need at least 20 samples

            // Calculate variance to detect if values are stuck
            let mean = history.reduce(0, +) / Float(history.count)
            let variance = history.map { pow($0 - mean, 2) }.reduce(0, +) / Float(history.count)
            let standardDeviation = sqrt(variance)

            // If standard deviation is very low and mean is also low, values might be stuck
            if standardDeviation < 0.02 && mean < 0.15 {
                print("⚠️ Gesture \(gesture.displayName) appears unresponsive - std dev: \(standardDeviation), mean: \(mean). Restarting session...")
                DispatchQueue.main.async {
                    self.restartARSession()
                }
                return
            }
        }
    }

    private func startPreviewCorruptionMonitoring() {
        previewCorruptionCheckTimer?.invalidate()
        lastPreviewUpdateTime = Date()

        previewCorruptionCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkPreviewCorruption()
        }
    }

    private func checkPreviewCorruption() {
        let timeSinceLastUpdate = Date().timeIntervalSince(lastPreviewUpdateTime)

        // If we haven't updated preview values in 5 seconds while in preview mode, something is wrong
        if timeSinceLastUpdate > 5.0 && isPreviewMode && isActive {
            print("⚠️ Preview values haven't updated in \(timeSinceLastUpdate)s - restarting preview mode")

            // Restart preview mode
            let currentGestures = Array(previewGestures)
            DispatchQueue.main.async {
                self.stopPreviewMode()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startPreviewMode(for: currentGestures)
                }
            }
        }
    }

    private func restartARSession() {
        print("🔄 Restarting ARKit session...")
        session.pause()

        // Clear gesture value history to start fresh
        gestureValueHistory.removeAll()
        lastGestureVarianceCheck = Date()

        // Small delay before restarting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.startARSession()
        }
    }
    
    func stopDetection() {
        sessionHealthTimer?.invalidate()
        sessionHealthTimer = nil
        session.pause()
        isActive = false
        gestureStates.removeAll()
        onGestureDetected = nil
    }
    
    func configureGesture(_ gesture: FacialGesture, threshold: Float, holdDuration: Double = 1.0) {
        gestureStates[gesture] = GestureState(threshold: threshold, holdDuration: holdDuration)
    }
    
    func removeGesture(_ gesture: FacialGesture) {
        gestureStates.removeValue(forKey: gesture)
    }

    // MARK: - Preview Mode Methods

    func startPreviewMode(for gestures: [FacialGesture]) {
        print("FacialGestureDetector.startPreviewMode called for gestures: \(gestures.map { $0.displayName })")

        guard isSupported else {
            print("Face tracking not supported")
            errorMessage = String(localized: "Face tracking is not supported on this device", comment: "Error message for unsupported device")
            return
        }

        // Setup preview mode
        isPreviewMode = true
        previewGestures = Set(gestures)
        previewGestureValues = [:]

        // Initialize preview values
        for gesture in gestures {
            previewGestureValues[gesture] = 0.0
        }

        print("Preview mode setup complete. isPreviewMode: \(isPreviewMode)")

        // Check camera permission before starting
        checkCameraPermission()
        print("Camera permission status: \(cameraPermissionStatus)")

        if cameraPermissionStatus == .authorized {
            // Permission already granted, start immediately
            print("Camera permission authorized, starting AR session")
            startARSession()
        } else if cameraPermissionStatus == .denied {
            print("Camera permission denied")
            errorMessage = String(localized: "Camera access denied. Please enable camera access in Settings to use facial gestures.", comment: "Error message for denied camera permission")
        } else {
            // Permission not determined, request it
            print("Camera permission not determined, requesting...")
            errorMessage = String(localized: "Camera access required for facial gesture detection.", comment: "Error message for camera permission needed")
            requestCameraPermission { [weak self] granted in
                print("Camera permission request result: \(granted)")
                if granted {
                    self?.startARSession()
                }
            }
        }
    }

    func stopPreviewMode() {
        sessionHealthTimer?.invalidate()
        sessionHealthTimer = nil
        previewCorruptionCheckTimer?.invalidate()
        previewCorruptionCheckTimer = nil
        isPreviewMode = false
        previewGestures.removeAll()
        previewGestureValues.removeAll()
        session.pause()
        isActive = false
    }

    // MARK: - Auto Detection Methods

    func startAutoDetectionMode(onComplete: @escaping (FacialGesture?) -> Void) {
        guard isSupported else {
            errorMessage = String(localized: "Face tracking is not supported on this device", comment: "Error message for unsupported device")
            return
        }

        self.onAutoDetectionComplete = onComplete
        isAutoDetectionMode = true
        autoDetectionBaseline.removeAll()
        autoDetectionCurrentValues.removeAll()
        autoDetectionResults.removeAll()
        detectedGestureNames.removeAll()

        // Check camera permission before starting
        checkCameraPermission()

        if cameraPermissionStatus == .authorized {
            startARSession()
        } else if cameraPermissionStatus == .denied {
            errorMessage = String(localized: "Camera access denied. Please enable camera access in Settings to use facial gestures.", comment: "Error message for denied camera permission")
        } else {
            requestCameraPermission { [weak self] granted in
                if granted {
                    self?.startARSession()
                }
            }
        }
    }

    func captureBaseline() {
        // Capture current gesture values as baseline
        autoDetectionBaseline = autoDetectionCurrentValues
        print("Captured baseline with \(autoDetectionBaseline.count) gestures")
    }

    func analyzeGestureChanges() -> FacialGesture? {
        guard !autoDetectionBaseline.isEmpty else {
            print("No baseline captured for analysis")
            return nil
        }

        var gestureChanges: [(gesture: FacialGesture, percentage: Float)] = []

        // Calculate percentage changes for all gestures
        for gesture in FacialGesture.allCases {
            let baseline = autoDetectionBaseline[gesture] ?? 0.0
            let current = autoDetectionCurrentValues[gesture] ?? 0.0

            // Calculate absolute change (avoiding division by zero)
            let change = abs(current - baseline)
            let percentageChange = baseline > 0.01 ? (change / baseline) : change

            autoDetectionResults[gesture] = percentageChange

            // Only include gestures with meaningful change (minimum threshold of 0.1)
            if percentageChange > 0.1 {
                gestureChanges.append((gesture: gesture, percentage: percentageChange))
            }
        }

        // Sort by percentage change (highest first)
        gestureChanges.sort { $0.percentage > $1.percentage }

        // Take top 5 results for display
        rankedGestures = Array(gestureChanges.prefix(5))

        let topGesture = gestureChanges.first?.gesture
        let maxChange = gestureChanges.first?.percentage ?? 0.0

        print("Analysis complete. Max change: \(maxChange) for gesture: \(topGesture?.displayName ?? "none")")
        print("Top 5 gestures: \(rankedGestures.map { "\($0.gesture.displayName): \(Int($0.percentage * 100))%" })")

        return topGesture
    }

    func stopAutoDetectionMode() {
        isAutoDetectionMode = false
        autoDetectionBaseline.removeAll()
        autoDetectionCurrentValues.removeAll()
        autoDetectionResults.removeAll()
        detectedGestureNames.removeAll()
        rankedGestures.removeAll()
        onAutoDetectionComplete = nil
        session.pause()
        isActive = false
    }
    
    // MARK: - Private Methods

    private func setupARKit() {
        isSupported = ARFaceTrackingConfiguration.isSupported
        session.delegate = self
    }

    private func checkCameraPermission() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    private func requestCameraPermission(completion: ((Bool) -> Void)? = nil) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.cameraPermissionStatus = granted ? .authorized : .denied
                if granted {
                    self?.errorMessage = nil
                } else {
                    self?.errorMessage = String(localized: "Camera access denied. Please enable camera access in Settings to use facial gestures.", comment: "Error message for denied camera permission")
                }
                completion?(granted)
            }
        }
    }
    
    private func processBlendShapes(_ blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        let currentTime = Date()

        // Handle preview mode
        if isPreviewMode {
            print("Processing preview mode for \(previewGestures.count) gestures")
            for gesture in previewGestures {
                let gestureValue = getGestureValue(for: gesture, from: blendShapes)
                print("Preview gesture \(gesture.displayName): value = \(gestureValue)")

                // Track gesture values for responsiveness monitoring
                trackGestureValue(gesture, value: gestureValue)

                DispatchQueue.main.async {
                    // Ensure we don't accidentally clear the value
                    if gestureValue >= 0.0 {
                        self.previewGestureValues[gesture] = gestureValue
                        self.lastPreviewUpdateTime = Date()
                        print("Updated previewGestureValues[\(gesture.displayName)] = \(gestureValue)")
                    } else {
                        print("⚠️ Skipping invalid gesture value: \(gestureValue) for \(gesture.displayName)")
                    }
                }
            }
            return
        }

        // Handle auto-detection mode
        if isAutoDetectionMode {
            var currentDetectedGestures: [String] = []

            for gesture in FacialGesture.allCases {
                let gestureValue = getGestureValue(for: gesture, from: blendShapes)
                autoDetectionCurrentValues[gesture] = gestureValue

                // Show real-time feedback for gestures above threshold
                if gestureValue > gesture.defaultThreshold {
                    currentDetectedGestures.append(gesture.displayName)
                }
            }

            DispatchQueue.main.async {
                self.detectedGestureNames = currentDetectedGestures
            }
            return
        }

        // Handle normal gesture detection
        for (gesture, state) in gestureStates {
            let gestureValue = getGestureValue(for: gesture, from: blendShapes)
            let isGestureActive = gestureValue >= state.threshold

            // Track gesture values for responsiveness monitoring
            trackGestureValue(gesture, value: gestureValue)

            var updatedState = state
            
            if isGestureActive && !state.isActive {
                // Gesture just started - record start time but don't trigger action yet
                updatedState.isActive = true
                updatedState.startTime = currentTime

            } else if !isGestureActive && state.isActive {
                // Gesture just ended - determine if it was tap or hold
                updatedState.isActive = false

                if let startTime = state.startTime {
                    let gestureDuration = currentTime.timeIntervalSince(startTime)
                    let isHoldGesture = gestureDuration >= state.holdDuration

                    // Trigger appropriate action based on duration
                    DispatchQueue.main.async {
                        self.onGestureDetected?(gesture, isHoldGesture)
                    }
                }

                updatedState.startTime = nil
                
            }
            
            gestureStates[gesture] = updatedState
        }
    }

    private func trackGestureValue(_ gesture: FacialGesture, value: Float) {
        // Initialize history array if needed
        if gestureValueHistory[gesture] == nil {
            gestureValueHistory[gesture] = []
        }

        // Add new value
        gestureValueHistory[gesture]?.append(value)

        // Keep only the last 30 values (about 1 second at 30 FPS)
        if let count = gestureValueHistory[gesture]?.count, count > 30 {
            gestureValueHistory[gesture]?.removeFirst()
        }
    }

    private func getGestureValue(for gesture: FacialGesture, from blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) -> Float {
        switch gesture {
        case .eyeBlinkEither:
            // Special case: either eye blink - use the maximum of both eye blink values
            let leftBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            let rightBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            return max(leftBlink, rightBlink)
        case .eyeBlinkLeft, .eyeBlinkRight:
            // Debug eye blink values to understand left/right mapping
            let leftBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            let rightBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            let targetValue = blendShapes[gesture.blendShapeLocation]?.floatValue ?? 0

            // Only log when there's significant activity
            if leftBlink > 0.1 || rightBlink > 0.1 {
                print("Eye values - ARKit Left: \(String(format: "%.3f", leftBlink)), ARKit Right: \(String(format: "%.3f", rightBlink)), Target(\(gesture.displayName)): \(String(format: "%.3f", targetValue))")
            }

            return targetValue
        default:
            return blendShapes[gesture.blendShapeLocation]?.floatValue ?? 0
        }
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard isActive else {
            print("Session update received but detector not active")
            return
        }

        // Throttle updates to prevent overwhelming the system (max 30 FPS)
        let currentTime = Date()
        let timeSinceLastUpdate = currentTime.timeIntervalSince(lastUpdateTime)
        guard timeSinceLastUpdate >= 0.033 else { // ~30 FPS limit
            return
        }
        lastUpdateTime = currentTime

        // Only process the most recent face anchor to avoid overwhelming the system
        if let faceAnchor = anchors.last(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor {
            // Update the last face anchor time for health monitoring
            lastFaceAnchorTime = currentTime

            if isPreviewMode {
                print("Processing face anchor in preview mode, blendShapes count: \(faceAnchor.blendShapes.count)")
            }

            // Extract blend shapes immediately to avoid retaining the ARFrame
            let blendShapes = faceAnchor.blendShapes

            // Process blend shapes asynchronously to release the frame immediately
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                self?.processBlendShapes(blendShapes)
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("ARKit session failed with error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.isActive = false
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("ARKit session was interrupted")
        DispatchQueue.main.async {
            self.isActive = false
        }
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        print("ARKit session interruption ended - restarting session")
        // Restart the session when interruption ends
        DispatchQueue.main.async {
            if self.isPreviewMode || self.isAutoDetectionMode || self.onGestureDetected != nil {
                print("Restarting ARKit session after interruption")
                self.startARSession()
            }
        }
    }
}
