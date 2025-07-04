//
//  FacialGestureDetector.swift
//  Echo
//
//  Created by Augment Agent on 04/07/2025.
//

import Foundation
import ARKit
import SwiftUI

class FacialGestureDetector: NSObject, ObservableObject, ARSessionDelegate {
    @Published var isActive: Bool = false
    @Published var isSupported: Bool = false
    @Published var errorMessage: String?
    
    private var session = ARSession()
    private var gestureStates: [FacialGesture: GestureState] = [:]
    private var onGestureDetected: ((FacialGesture, Bool) -> Void)?
    
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
        
        self.onGestureDetected = onGestureDetected
        
        let configuration = ARFaceTrackingConfiguration()
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        isActive = true
        errorMessage = nil
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
    
    // MARK: - Private Methods
    
    private func setupARKit() {
        isSupported = ARFaceTrackingConfiguration.isSupported
        session.delegate = self
    }
    
    private func processBlendShapes(_ blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        let currentTime = Date()
        
        for (gesture, state) in gestureStates {
            let gestureValue = getGestureValue(for: gesture, from: blendShapes)
            let isGestureActive = gestureValue >= state.threshold
            
            var updatedState = state
            
            if isGestureActive && !state.isActive {
                // Gesture just started
                updatedState.isActive = true
                updatedState.startTime = currentTime
                
                // Trigger tap action immediately
                DispatchQueue.main.async {
                    self.onGestureDetected?(gesture, false) // false = tap action
                }
                
            } else if !isGestureActive && state.isActive {
                // Gesture just ended
                updatedState.isActive = false
                updatedState.startTime = nil
                
            } else if isGestureActive && state.isActive {
                // Gesture is continuing - check for hold action
                if let startTime = state.startTime {
                    let duration = currentTime.timeIntervalSince(startTime)
                    if duration >= state.holdDuration {
                        // Trigger hold action and reset start time to prevent repeated triggers
                        updatedState.startTime = currentTime
                        
                        DispatchQueue.main.async {
                            self.onGestureDetected?(gesture, true) // true = hold action
                        }
                    }
                }
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
