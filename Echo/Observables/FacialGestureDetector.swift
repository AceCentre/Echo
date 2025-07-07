//
//  FacialGestureDetector.swift
//  Echo
//
//  Created by Augment Agent on 04/07/2025.
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
    
    private var session = ARSession()
    private var gestureStates: [FacialGesture: GestureState] = [:]
    private var onGestureDetected: ((FacialGesture, Bool) -> Void)?
    private var previewGestures: Set<FacialGesture> = []
    
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
        let configuration = ARFaceTrackingConfiguration()
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        DispatchQueue.main.async {
            self.isActive = true
            self.errorMessage = nil
        }
    }
    
    func stopDetection() {
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
        guard isSupported else {
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

    func stopPreviewMode() {
        isPreviewMode = false
        previewGestures.removeAll()
        previewGestureValues.removeAll()
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
            for gesture in previewGestures {
                let gestureValue = getGestureValue(for: gesture, from: blendShapes)
                DispatchQueue.main.async {
                    self.previewGestureValues[gesture] = gestureValue
                }
            }
            return
        }

        // Handle normal gesture detection
        for (gesture, state) in gestureStates {
            let gestureValue = getGestureValue(for: gesture, from: blendShapes)
            let isGestureActive = gestureValue >= state.threshold
            
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
    
    private func getGestureValue(for gesture: FacialGesture, from blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) -> Float {
        switch gesture {
        case .eyeBlinkBoth:
            // Special case: both eyes blink - use the minimum of both eye blink values
            let leftBlink = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
            let rightBlink = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
            return min(leftBlink, rightBlink)
        case .eyeBlinkLeft, .eyeBlinkRight:
            // Debug eye blink values - note that coordinates are now corrected for user perspective
            let leftBlinkCamera = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0  // Camera's left
            let rightBlinkCamera = blendShapes[.eyeBlinkRight]?.floatValue ?? 0  // Camera's right
            let targetValue = blendShapes[gesture.blendShapeLocation]?.floatValue ?? 0

            // Only log when there's significant activity
            if leftBlinkCamera > 0.1 || rightBlinkCamera > 0.1 {
                // Show from user's perspective (corrected)
                let userLeftBlink = rightBlinkCamera  // User's left = camera's right
                let userRightBlink = leftBlinkCamera  // User's right = camera's left
                print("Eye values (user perspective) - Left: \(String(format: "%.3f", userLeftBlink)), Right: \(String(format: "%.3f", userRightBlink)), Target(\(gesture.displayName)): \(String(format: "%.3f", targetValue))")
            }

            return targetValue
        default:
            return blendShapes[gesture.blendShapeLocation]?.floatValue ?? 0
        }
    }
    
    // MARK: - ARSessionDelegate
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard isActive else { return }
        
        for anchor in anchors {
            if let faceAnchor = anchor as? ARFaceAnchor {
                processBlendShapes(faceAnchor.blendShapes)
            }
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
            self.isActive = false
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async {
            self.isActive = false
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Session interruption ended - could restart if needed
    }
}
