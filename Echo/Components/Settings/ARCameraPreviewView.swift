//
//  ARCameraPreviewView.swift
//  Echo
//
//  Created by Will Wade on 08/07/2025.
//

import SwiftUI
import ARKit
import SceneKit

/// A SwiftUI wrapper for ARSCNView that displays live camera feed with face tracking
struct ARCameraPreviewView: UIViewRepresentable {
    @ObservedObject var gestureDetector: FacialGestureDetector
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView()
        
        // Configure the AR view
        arView.session = gestureDetector.session
        arView.automaticallyUpdatesLighting = true
        arView.showsStatistics = false
        
        // Set up the scene
        let scene = SCNScene()
        arView.scene = scene
        
        // Configure camera settings for better face tracking
        arView.preferredFramesPerSecond = 60
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // Update the session if needed
        uiView.session = gestureDetector.session
    }
}

/// A camera preview view specifically designed for facial gesture auto-detection
struct FacialGestureAutoDetectCameraView: View {
    @ObservedObject var gestureDetector: FacialGestureDetector
    let overlayText: String
    let detectedGestures: [String]
    
    var body: some View {
        ZStack {
            // Camera preview
            ARCameraPreviewView(gestureDetector: gestureDetector)
                .clipped()
            
            // Overlay content
            VStack {
                Spacer()
                
                // Instructional text at the bottom
                VStack(spacing: 8) {
                    Text(overlayText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 2, x: 1, y: 1)
                        .multilineTextAlignment(.center)
                    
                    // Real-time gesture feedback
                    if !detectedGestures.isEmpty {
                        VStack(spacing: 4) {
                            Text("Detected Gestures:")
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
                            
                            ForEach(detectedGestures, id: \.self) { gesture in
                                Text(gesture)
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .fontWeight(.semibold)
                                    .shadow(color: .black, radius: 1, x: 0.5, y: 0.5)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.3))
                        .cornerRadius(8)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .background(Color.black)
    }
}

#Preview {
    FacialGestureAutoDetectCameraView(
        gestureDetector: FacialGestureDetector(),
        overlayText: "After 3 make your gesture... 1, 2, 3!",
        detectedGestures: ["Left Eye Blink", "Smile"]
    )
}
