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

extension Notification.Name {
    static let autoSelectActiveChanged = Notification.Name("autoSelectActiveChanged")
    static let previewModeActiveChanged = Notification.Name("previewModeActiveChanged")
}

class FacialGestureDetector: NSObject, ObservableObject, ARSessionDelegate {
    static let shared = FacialGestureDetector()

    @Published var isActive: Bool = false
    @Published var isSupported: Bool = false
    @Published var errorMessage: String?
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined

    // Session mode tracking
    enum SessionMode {
        case inactive
        case navigation    // Main app gesture detection
        case preview      // Settings test gesture mode
        case autoSelect   // Auto-select gesture discovery
    }

    @Published var currentMode: SessionMode = .inactive

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

    // Coordination between main app and auto-select
    static var isAutoSelectActive: Bool = false {
        didSet {
            if isAutoSelectActive != oldValue {
                EchoLogger.facialGesture("FacialGestureDetector.isAutoSelectActive changed to: \(isAutoSelectActive)")
                NotificationCenter.default.post(name: .autoSelectActiveChanged, object: nil, userInfo: ["isActive": isAutoSelectActive])
            }
        }
    }

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

    // Head tracking properties
    private var baselineHeadTransform: simd_float4x4?
    private var currentHeadTransform: simd_float4x4?
    private var headTrackingInitialized: Bool = false
    private var lastBaselineResetTime: Date = Date()
    private var baselineResetCooldown: TimeInterval = 2.0 // Minimum time between baseline resets
    
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

    /// Stops all detection modes and cleans up session
    private func stopAllModes() {
        EchoLogger.facialGesture("FacialGestureDetector.stopAllModes called - current mode: \(currentMode)")

        // Stop timers
        sessionHealthTimer?.invalidate()
        sessionHealthTimer = nil
        previewCorruptionCheckTimer?.invalidate()
        previewCorruptionCheckTimer = nil

        // Clear all state
        isPreviewMode = false
        isAutoDetectionMode = false
        previewGestures.removeAll()
        previewGestureValues.removeAll()
        autoDetectionBaseline.removeAll()
        autoDetectionCurrentValues.removeAll()
        autoDetectionResults.removeAll()
        detectedGestureNames.removeAll()
        rankedGestures.removeAll()
        onGestureDetected = nil
        onAutoDetectionComplete = nil

        // Reset head tracking
        baselineHeadTransform = nil
        currentHeadTransform = nil
        headTrackingInitialized = false
        lastBaselineResetTime = Date()

        // Pause session
        session.pause()
        isActive = false
        currentMode = .inactive

        EchoLogger.facialGesture("All modes stopped, session paused")
    }

    func startDetection(onGestureDetected: @escaping (FacialGesture, Bool) -> Void) {
        EchoLogger.facialGesture("FacialGestureDetector.startDetection called - switching to navigation mode")

        guard isSupported else {
            errorMessage = String(localized: "Face tracking is not supported on this device", comment: "Error message for unsupported device")
            return
        }

        // Stop any existing session first
        stopAllModes()

        // Store the callback and set mode
        self.onGestureDetected = onGestureDetected
        currentMode = .navigation

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
        EchoLogger.debug("startARSession called", category: .facialGesture)

        // Configure ARKit to be more resource-friendly
        let configuration = ARFaceTrackingConfiguration()

        // Reduce resource usage to prevent conflicts with audio system
        if #available(iOS 13.0, *) {
            configuration.maximumNumberOfTrackedFaces = 1 // Only track one face
        }

        EchoLogger.debug("Running AR session with configuration", category: .facialGesture)
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        DispatchQueue.main.async {
            EchoLogger.debug("Setting isActive to true on main queue", category: .facialGesture)
            self.isActive = true
            self.errorMessage = nil
            EchoLogger.debug("isActive is now: \(self.isActive)", category: .facialGesture)

            // Start session health monitoring
            self.startSessionHealthMonitoring()
        }
    }

    private func startSessionHealthMonitoring() {
        // Stop any existing timer
        sessionHealthTimer?.invalidate()

        // Start a timer to check if we're still receiving face anchors (check every 5 seconds)
        sessionHealthTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkSessionHealth()
        }

        // Start preview corruption monitoring if in preview mode
        if isPreviewMode {
            startPreviewCorruptionMonitoring()
        }
    }

    private func checkSessionHealth() {
        let timeSinceLastFaceAnchor = Date().timeIntervalSince(lastFaceAnchorTime)

        // Increase restart threshold to 30 seconds to reduce frequent restarts that cause audio conflicts
        // Only restart if we haven't received face anchors for a longer period
        // and only if we're actively supposed to be detecting
        if timeSinceLastFaceAnchor > 30.0 && isActive && (isPreviewMode || isAutoDetectionMode || onGestureDetected != nil) {
            EchoLogger.warning("ARKit session appears stuck - no face anchors for \(timeSinceLastFaceAnchor)s. Restarting...", category: .facialGesture)
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

            // Temporarily disable aggressive corruption detection as it's causing more problems than it solves
            // The constant session restarts are making gestures "sticky" and unresponsive
            // TODO: Implement more intelligent corruption detection that doesn't interfere with normal operation

            // If standard deviation is very low and mean is also low, values might be stuck
            // But exclude gaze direction gestures which naturally have low values when not actively looking
            let isGazeGesture = [FacialGesture.lookUp, .lookDown, .lookLeft, .lookRight].contains(gesture)

            // Only restart for extreme cases where values are completely frozen
            if standardDeviation < 0.001 && mean < 0.001 && !isGazeGesture {
                EchoLogger.warning("Gesture \(gesture.displayName) appears completely frozen - std dev: \(standardDeviation), mean: \(mean). Restarting session...", category: .facialGesture)
                DispatchQueue.main.async {
                    self.restartARSession()
                }
                return
            } else if isGazeGesture && standardDeviation < 0.0001 && mean < 0.0001 {
                // For gaze gestures, only restart if values are completely stuck at 0 for a long time
                EchoLogger.warning("Gaze gesture \(gesture.displayName) appears completely stuck - std dev: \(standardDeviation), mean: \(mean). Restarting session...", category: .facialGesture)
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
            EchoLogger.warning("Preview values haven't updated in \(timeSinceLastUpdate)s - restarting preview mode", category: .facialGesture)

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
        EchoLogger.warning("Restarting ARKit session...", category: .facialGesture)
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
        EchoLogger.facialGesture("FacialGestureDetector.stopDetection called")
        stopAllModes()
    }
    
    func configureGesture(_ gesture: FacialGesture, threshold: Float, holdDuration: Double = 1.0) {
        gestureStates[gesture] = GestureState(threshold: threshold, holdDuration: holdDuration)
    }
    
    func removeGesture(_ gesture: FacialGesture) {
        gestureStates.removeValue(forKey: gesture)
    }

    func resetHeadBaseline() {
        EchoLogger.facialGesture("Resetting head tracking baseline")
        baselineHeadTransform = currentHeadTransform
        headTrackingInitialized = true
    }

    // MARK: - Preview Mode Methods

    func startPreviewMode(for gestures: [FacialGesture]) {
        EchoLogger.facialGesture("FacialGestureDetector.startPreviewMode called for gestures: \(gestures.map { $0.displayName }) - switching to preview mode")

        guard isSupported else {
            EchoLogger.facialGesture("Face tracking not supported")
            errorMessage = String(localized: "Face tracking is not supported on this device", comment: "Error message for unsupported device")
            return
        }

        // Stop any existing session first
        stopAllModes()

        // Setup preview mode
        isPreviewMode = true
        currentMode = .preview
        previewGestures = Set(gestures)
        previewGestureValues = [:]

        // Initialize preview values
        for gesture in gestures {
            previewGestureValues[gesture] = 0.0
        }

        EchoLogger.facialGesture("Preview mode setup complete, starting AR session...")

        // Notify that preview mode is now active
        NotificationCenter.default.post(name: .previewModeActiveChanged, object: true)

        // Check camera permission before starting
        checkCameraPermission()

        if cameraPermissionStatus == .authorized {
            // Permission already granted, start immediately
            EchoLogger.facialGesture("Camera permission authorized, starting AR session for preview mode")
            startARSession()
        } else if cameraPermissionStatus == .denied {
            EchoLogger.facialGesture("Camera permission denied")
            errorMessage = String(localized: "Camera access denied. Please enable camera access in Settings to use facial gestures.", comment: "Error message for denied camera permission")
        } else {
            // Permission not determined, request it
            EchoLogger.facialGesture("Camera permission not determined, requesting...")
            errorMessage = String(localized: "Camera access required for facial gesture detection.", comment: "Error message for camera permission needed")
            requestCameraPermission { [weak self] granted in
                EchoLogger.facialGesture("Camera permission request result: \(granted)")
                if granted {
                    self?.startARSession()
                }
            }
        }
    }

    func stopPreviewMode() {
        EchoLogger.facialGesture("FacialGestureDetector.stopPreviewMode called")
        stopAllModes()

        // Notify that preview mode is no longer active
        NotificationCenter.default.post(name: .previewModeActiveChanged, object: false)
    }

    /// Stops all detection and ensures clean state for navigation transitions
    func stopForNavigation() {
        EchoLogger.facialGesture("FacialGestureDetector.stopForNavigation called - preparing for navigation transition")
        stopAllModes()
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

        EchoLogger.debug("Analysis complete. Max change: \(maxChange) for gesture: \(topGesture?.displayName ?? "none")", category: .facialGesture)
        EchoLogger.debug("Top 5 gestures: \(rankedGestures.map { "\($0.gesture.displayName): \(Int($0.percentage * 100))%" })", category: .facialGesture)

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

        // Reset head tracking
        baselineHeadTransform = nil
        currentHeadTransform = nil
        headTrackingInitialized = false
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
            for gesture in previewGestures {
                let gestureValue = getGestureValue(for: gesture, from: blendShapes)

                // Track gesture values for responsiveness monitoring
                trackGestureValue(gesture, value: gestureValue)

                DispatchQueue.main.async {
                    // Ensure we don't accidentally clear the value
                    if gestureValue >= 0.0 {
                        self.previewGestureValues[gesture] = gestureValue
                        self.lastPreviewUpdateTime = Date()
                    } else {
                        EchoLogger.warning("Skipping invalid gesture value: \(gestureValue) for \(gesture.displayName)", category: .facialGesture)
                    }
                }
            }
            return
        }

        // Handle auto-detection mode
        if isAutoDetectionMode {
            var currentDetectedGestures: [String] = []
            var currentValues: [FacialGesture: Float] = [:]

            for gesture in FacialGesture.allCases {
                let gestureValue = getGestureValue(for: gesture, from: blendShapes)
                currentValues[gesture] = gestureValue

                // Show real-time feedback for gestures above threshold
                if gestureValue > gesture.defaultThreshold {
                    currentDetectedGestures.append(gesture.displayName)
                }
            }

            DispatchQueue.main.async {
                self.autoDetectionCurrentValues = currentValues
                self.detectedGestureNames = currentDetectedGestures
            }
            return
        }

        // Handle normal gesture detection
        var stateUpdates: [FacialGesture: GestureState] = [:]
        var gestureCallbacks: [(FacialGesture, Bool)] = []

        // Thread-safe access: get a snapshot of current gesture states
        var currentGestureStates: [FacialGesture: GestureState] = [:]
        DispatchQueue.main.sync {
            currentGestureStates = gestureStates
        }

        for (gesture, state) in currentGestureStates {
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

                    // Store callback for main thread execution
                    gestureCallbacks.append((gesture, isHoldGesture))
                }

                updatedState.startTime = nil
            }

            stateUpdates[gesture] = updatedState
        }

        // Update all state on main thread
        DispatchQueue.main.async {
            for (gesture, updatedState) in stateUpdates {
                self.gestureStates[gesture] = updatedState
            }

            // Execute gesture callbacks
            for (gesture, isHoldGesture) in gestureCallbacks {
                self.onGestureDetected?(gesture, isHoldGesture)
            }
        }
    }

    private func trackGestureValue(_ gesture: FacialGesture, value: Float) {
        // Thread-safe access to gestureValueHistory
        DispatchQueue.main.async {
            // Initialize history array if needed
            if self.gestureValueHistory[gesture] == nil {
                self.gestureValueHistory[gesture] = []
            }

            // Add new value
            self.gestureValueHistory[gesture]?.append(value)

            // Keep only the last 30 values (about 1 second at 30 FPS)
            if let count = self.gestureValueHistory[gesture]?.count, count > 30 {
                self.gestureValueHistory[gesture]?.removeFirst()
            }
        }
    }

    private func getGestureValue(for gesture: FacialGesture, from blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) -> Float {
        let rawValue: Float

        switch gesture {
        case .eyeBlinkEither:
            // Special case: either eye blink - use the maximum of both eye blink values
            let leftBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            let rightBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            rawValue = max(leftBlink, rightBlink)
        case .eyeBlinkLeft, .eyeBlinkRight:
            rawValue = blendShapes[gesture.blendShapeLocation]?.floatValue ?? 0
        case .eyeOpenLeft, .eyeOpenRight, .eyeOpenEither:
            // Eye open gestures: same as blink but inverted (detects when eyes are open)
            if gesture == .eyeOpenEither {
                let leftBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
                let rightBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
                rawValue = max(leftBlink, rightBlink)
            } else {
                rawValue = blendShapes[gesture.blendShapeLocation]?.floatValue ?? 0
            }
        case .lookUp:
            // Look up: use average of both eyes looking up
            let leftLookUp = blendShapes[.eyeLookUpLeft]?.floatValue ?? 0
            let rightLookUp = blendShapes[.eyeLookUpRight]?.floatValue ?? 0
            // Use average for more stable detection
            let upAvg = (leftLookUp + rightLookUp) / 2.0
            // Subtract down values to get net upward gaze
            let leftLookDown = blendShapes[.eyeLookDownLeft]?.floatValue ?? 0
            let rightLookDown = blendShapes[.eyeLookDownRight]?.floatValue ?? 0
            let downAvg = (leftLookDown + rightLookDown) / 2.0
            // Net upward gaze (clamp to avoid negative values)
            rawValue = max(0, upAvg - (downAvg * 0.5))

            // Debug logging for eye look gestures
            if isPreviewMode && upAvg > 0.01 {
                EchoLogger.eyeTracking("Look Up debug - leftUp: \(leftLookUp), rightUp: \(rightLookUp), upAvg: \(upAvg), downAvg: \(downAvg), final: \(rawValue)")
            }
        case .lookDown:
            // Look down: use average of both eyes looking down
            let leftLookDown = blendShapes[.eyeLookDownLeft]?.floatValue ?? 0
            let rightLookDown = blendShapes[.eyeLookDownRight]?.floatValue ?? 0
            // Use average for more stable detection
            let downAvg = (leftLookDown + rightLookDown) / 2.0
            // Subtract up values to get net downward gaze
            let leftLookUp = blendShapes[.eyeLookUpLeft]?.floatValue ?? 0
            let rightLookUp = blendShapes[.eyeLookUpRight]?.floatValue ?? 0
            let upAvg = (leftLookUp + rightLookUp) / 2.0
            // Net downward gaze (clamp to avoid negative values)
            rawValue = max(0, downAvg - (upAvg * 0.5))
        case .lookLeft:
            // Look left: left eye looks in (toward nose), right eye looks out (away from nose)
            let leftLookIn = blendShapes[.eyeLookInLeft]?.floatValue ?? 0
            let rightLookOut = blendShapes[.eyeLookOutRight]?.floatValue ?? 0
            // Use average of both eyes for more stable detection
            rawValue = (leftLookIn + rightLookOut) / 2.0
        case .lookRight:
            // Look right: left eye looks out (away from nose), right eye looks in (toward nose)
            let leftLookOut = blendShapes[.eyeLookOutLeft]?.floatValue ?? 0
            let rightLookIn = blendShapes[.eyeLookInRight]?.floatValue ?? 0
            // Use average of both eyes for more stable detection
            rawValue = (leftLookOut + rightLookIn) / 2.0
        case .headNodUp, .headNodDown, .headShakeLeft, .headShakeRight, .headTiltLeft, .headTiltRight:
            // Head movement gestures are handled separately in processHeadTransform
            // Return 0 here as these values are updated directly in preview/auto-detection modes
            return 0
        default:
            rawValue = blendShapes[gesture.blendShapeLocation]?.floatValue ?? 0
        }

        // Apply inversion if needed for gestures that have inverted behavior
        if gesture.isInverted {
            return processInvertedGesture(rawValue, for: gesture)
        } else {
            return rawValue
        }
    }

    private func processInvertedGesture(_ rawValue: Float, for gesture: FacialGesture) -> Float {
        switch gesture {
        case .mouthClose:
            // For mouthClose: ARKit reports higher values when mouth is more open
            // We want higher values when mouth is more closed
            //
            // Strategy: Only register mouth close when actively closing from neutral
            // - Neutral/open mouth (rawValue 0.2+): output = 0.0 (no detection)
            // - Closing mouth (rawValue < 0.2): output scales from 0.0 to 1.0

            let neutralThreshold: Float = 0.2

            // If mouth is at or above neutral position, no mouth close detected
            if rawValue >= neutralThreshold {
                return 0.0
            }

            // Scale the closing amount: rawValue 0.2 → 0.0, rawValue 0.0 → 1.0
            let closingRatio = (neutralThreshold - rawValue) / neutralThreshold
            return min(1.0, max(0.0, closingRatio))

        default:
            // Default simple inversion for other inverted gestures
            return 1.0 - rawValue
        }
    }

    private func processHeadTransform(_ transform: simd_float4x4) {
        currentHeadTransform = transform

        // Initialize baseline if this is the first frame
        if !headTrackingInitialized {
            baselineHeadTransform = transform
            headTrackingInitialized = true
            lastBaselineResetTime = Date()
            EchoLogger.facialGesture("Head tracking baseline initialized")
            return
        }

        guard let baseline = baselineHeadTransform else { return }

        // Calculate relative transform (current relative to baseline)
        let relativeTransform = simd_mul(transform, simd_inverse(baseline))

        // Check if baseline needs to be reset due to extreme values
        let currentTime = Date()
        let timeSinceLastReset = currentTime.timeIntervalSince(lastBaselineResetTime)

        if timeSinceLastReset > baselineResetCooldown {
            // Extract rotation to check for extreme values
            let rotationMatrix = simd_float3x3(
                simd_float3(relativeTransform.columns.0.x, relativeTransform.columns.0.y, relativeTransform.columns.0.z),
                simd_float3(relativeTransform.columns.1.x, relativeTransform.columns.1.y, relativeTransform.columns.1.z),
                simd_float3(relativeTransform.columns.2.x, relativeTransform.columns.2.y, relativeTransform.columns.2.z)
            )

            // Convert to Euler angles to check for extreme rotations
            let eulerAngles = extractEulerAngles(from: rotationMatrix)
            let maxAngle = max(abs(eulerAngles.x), abs(eulerAngles.y), abs(eulerAngles.z))

            // If any angle exceeds 90 degrees (1.57 radians), reset baseline
            if maxAngle > 1.57 {
                EchoLogger.facialGesture("Resetting head tracking baseline due to extreme rotation: \(maxAngle) radians")
                baselineHeadTransform = transform
                lastBaselineResetTime = currentTime
                return
            }
        }

        // Extract rotation using a more robust method
        // ARKit face coordinate system: X=right, Y=up, Z=forward (toward user)
        let rotationMatrix = simd_float3x3(
            simd_float3(relativeTransform.columns.0.x, relativeTransform.columns.0.y, relativeTransform.columns.0.z),
            simd_float3(relativeTransform.columns.1.x, relativeTransform.columns.1.y, relativeTransform.columns.1.z),
            simd_float3(relativeTransform.columns.2.x, relativeTransform.columns.2.y, relativeTransform.columns.2.z)
        )

        // Extract Euler angles with proper ARKit coordinate system
        // Pitch: rotation around X-axis (nod up/down)
        // Yaw: rotation around Y-axis (shake left/right)
        // Roll: rotation around Z-axis (tilt left/right)
        let pitch = atan2(-rotationMatrix[2][1], sqrt(rotationMatrix[2][0] * rotationMatrix[2][0] + rotationMatrix[2][2] * rotationMatrix[2][2]))
        let yaw = atan2(rotationMatrix[2][0], rotationMatrix[2][2])
        let roll = atan2(-rotationMatrix[0][1], rotationMatrix[1][1])



        // Update head movement gesture values based on rotation
        updateHeadMovementGestures(pitch: pitch, yaw: yaw, roll: roll)
    }

    private func updateHeadMovementGestures(pitch: Float, yaw: Float, roll: Float) {
        // Calculate gesture values with proper directional logic
        let headNodUpValue = max(0, pitch)      // Positive pitch = nod up
        let headNodDownValue = max(0, -pitch)   // Negative pitch = nod down
        let headShakeLeftValue = max(0, -yaw)   // Negative yaw = shake left
        let headShakeRightValue = max(0, yaw)   // Positive yaw = shake right
        let headTiltLeftValue = max(0, -roll)   // Negative roll = tilt left
        let headTiltRightValue = max(0, roll)   // Positive roll = tilt right

        // Update gesture values for preview mode
        if isPreviewMode {
            DispatchQueue.main.async {
                self.previewGestureValues[.headNodUp] = headNodUpValue
                self.previewGestureValues[.headNodDown] = headNodDownValue
                self.previewGestureValues[.headShakeLeft] = headShakeLeftValue
                self.previewGestureValues[.headShakeRight] = headShakeRightValue
                self.previewGestureValues[.headTiltLeft] = headTiltLeftValue
                self.previewGestureValues[.headTiltRight] = headTiltRightValue
            }
        }

        // Update auto-detection values
        if isAutoDetectionMode {
            autoDetectionCurrentValues[.headNodUp] = headNodUpValue
            autoDetectionCurrentValues[.headNodDown] = headNodDownValue
            autoDetectionCurrentValues[.headShakeLeft] = headShakeLeftValue
            autoDetectionCurrentValues[.headShakeRight] = headShakeRightValue
            autoDetectionCurrentValues[.headTiltLeft] = headTiltLeftValue
            autoDetectionCurrentValues[.headTiltRight] = headTiltRightValue
        }

        // Handle normal gesture detection for head movements
        let headGestures: [FacialGesture] = [.headNodUp, .headNodDown, .headShakeLeft, .headShakeRight, .headTiltLeft, .headTiltRight]

        // Collect state updates and callbacks to execute on main thread (thread safety)
        var stateUpdates: [FacialGesture: GestureState] = [:]
        var gestureCallbacks: [(FacialGesture, Bool)] = []
        let currentTime = Date()

        for gesture in headGestures {
            // Thread-safe access: read current state on main thread
            var currentState: GestureState?
            DispatchQueue.main.sync {
                currentState = gestureStates[gesture]
            }

            guard let state = currentState else { continue }

            let gestureValue = getHeadGestureValue(for: gesture, pitch: pitch, yaw: yaw, roll: roll)
            let isGestureActive = gestureValue >= state.threshold

            var updatedState = state

            if isGestureActive && !state.isActive {
                // Gesture just started
                updatedState.isActive = true
                updatedState.startTime = currentTime
            } else if !isGestureActive && state.isActive {
                // Gesture just ended - determine if it was tap or hold
                updatedState.isActive = false

                if let startTime = state.startTime {
                    let gestureDuration = currentTime.timeIntervalSince(startTime)
                    let isHoldGesture = gestureDuration >= state.holdDuration

                    // Store callback for main thread execution
                    gestureCallbacks.append((gesture, isHoldGesture))
                }

                updatedState.startTime = nil
            }

            stateUpdates[gesture] = updatedState
        }

        // Update all state and execute callbacks on main thread (thread safety)
        DispatchQueue.main.async {
            for (gesture, updatedState) in stateUpdates {
                self.gestureStates[gesture] = updatedState
            }

            // Execute gesture callbacks
            for (gesture, isHoldGesture) in gestureCallbacks {
                self.onGestureDetected?(gesture, isHoldGesture)
            }
        }
    }

    private func getHeadGestureValue(for gesture: FacialGesture, pitch: Float, yaw: Float, roll: Float) -> Float {
        switch gesture {
        case .headNodUp:
            return max(0, pitch)      // Positive pitch = nod up
        case .headNodDown:
            return max(0, -pitch)     // Negative pitch = nod down
        case .headShakeLeft:
            return max(0, -yaw)       // Negative yaw = shake left
        case .headShakeRight:
            return max(0, yaw)        // Positive yaw = shake right
        case .headTiltLeft:
            return max(0, -roll)      // Negative roll = tilt left
        case .headTiltRight:
            return max(0, roll)       // Positive roll = tilt right
        default:
            return 0
        }
    }

    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard isActive else {
            print("Session update received but detector not active")
            return
        }

        // Throttle updates to prevent overwhelming the system (max 20 FPS for better performance)
        let currentTime = Date()
        let timeSinceLastUpdate = currentTime.timeIntervalSince(lastUpdateTime)
        guard timeSinceLastUpdate >= 0.05 else { // ~20 FPS limit (reduced from 30 FPS)
            return
        }
        lastUpdateTime = currentTime

        // Only process the most recent face anchor to avoid overwhelming the system
        if let faceAnchor = anchors.last(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor {
            // Update the last face anchor time for health monitoring
            lastFaceAnchorTime = currentTime

            // Extract data immediately and copy to avoid frame retention
            let blendShapes = faceAnchor.blendShapes
            let headTransform = faceAnchor.transform

            // Process asynchronously on a background queue to avoid blocking the ARKit thread
            // This prevents frame retention by allowing ARKit to release frames immediately
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                self?.processBlendShapes(blendShapes)
                self?.processHeadTransform(headTransform)
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

    // MARK: - Helper Functions

    private func extractEulerAngles(from rotationMatrix: simd_float3x3) -> simd_float3 {
        // Extract Euler angles from rotation matrix (ZYX order)
        let sy = sqrt(rotationMatrix[0][0] * rotationMatrix[0][0] + rotationMatrix[1][0] * rotationMatrix[1][0])

        let singular = sy < 1e-6

        let x: Float
        let y: Float
        let z: Float

        if !singular {
            x = atan2(rotationMatrix[2][1], rotationMatrix[2][2])
            y = atan2(-rotationMatrix[2][0], sy)
            z = atan2(rotationMatrix[1][0], rotationMatrix[0][0])
        } else {
            x = atan2(-rotationMatrix[1][2], rotationMatrix[1][1])
            y = atan2(-rotationMatrix[2][0], sy)
            z = 0
        }

        return simd_float3(x, y, z)
    }
}
