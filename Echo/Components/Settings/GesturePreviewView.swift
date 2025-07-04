//
//  GesturePreviewView.swift
//  Echo
//
//  Created by Augment Agent on 04/07/2025.
//

import SwiftUI
import ARKit

struct GesturePreviewView: View {
    let gesture: FacialGesture
    let threshold: Float
    @StateObject private var detector = FacialGestureDetector()
    @State private var isActive = false
    
    var gestureValue: Float {
        detector.previewGestureValues[gesture] ?? 0.0
    }
    
    var isGestureDetected: Bool {
        gestureValue >= threshold
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Preview: \(gesture.displayName)")
                    .font(.headline)
                Spacer()
                Button(action: {
                    if isActive {
                        stopPreview()
                    } else {
                        startPreview()
                    }
                }) {
                    Label(
                        isActive ? "Stop" : "Start",
                        systemImage: isActive ? "stop.circle.fill" : "play.circle.fill"
                    )
                    .foregroundColor(isActive ? .red : .green)
                }
            }
            
            if isActive {
                // Gesture strength indicator
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Gesture Strength:")
                        Spacer()
                        Text("\(Int(gestureValue * 100))%")
                            .foregroundColor(isGestureDetected ? .green : .primary)
                            .fontWeight(isGestureDetected ? .bold : .regular)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            // Threshold line
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: 2, height: 12)
                                .offset(x: CGFloat(threshold) * geometry.size.width - 1)
                            
                            // Current value
                            Rectangle()
                                .fill(isGestureDetected ? Color.green : Color.blue)
                                .frame(width: CGFloat(gestureValue) * geometry.size.width, height: 8)
                                .cornerRadius(4)
                                .animation(.easeInOut(duration: 0.1), value: gestureValue)
                        }
                    }
                    .frame(height: 12)
                    
                    // Labels
                    HStack {
                        Text("0%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Threshold: \(Int(threshold * 100))%")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Spacer()
                        Text("100%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    // Detection status
                    if isGestureDetected {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Gesture Detected!")
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                        }
                        .transition(.opacity)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Instructions
                Text(gesture.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                // Not active state
                VStack(spacing: 8) {
                    Image(systemName: "face.dashed")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("Tap Start to begin gesture preview")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !detector.isSupported {
                        Text("Face tracking not supported on this device")
                            .font(.caption)
                            .foregroundColor(.red)
                    } else if detector.cameraPermissionStatus == .denied {
                        Text("Camera access required for preview")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            if let errorMessage = detector.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
        .onDisappear {
            stopPreview()
        }
    }
    
    private func startPreview() {
        guard detector.isSupported else { return }
        
        detector.startPreviewMode(for: [gesture])
        isActive = true
    }
    
    private func stopPreview() {
        detector.stopPreviewMode()
        isActive = false
    }
}

#Preview {
    GesturePreviewView(
        gesture: .eyeBlinkLeft,
        threshold: 0.8
    )
    .padding()
}
