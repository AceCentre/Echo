//
//  GesturePreviewView.swift
//  Echo
//
//  Created by Will Wade on 04/07/2025.
//

import SwiftUI
import ARKit

struct GesturePreviewView: View {
    let gesture: FacialGesture
    let threshold: Float
    @StateObject private var detector = FacialGestureDetector.shared
    @State private var isActive = false
    @State private var currentGestureValue: Float = 0.0

    var gestureValue: Float {
        return currentGestureValue
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
                    
                    // Progress bar with enhanced threshold indicator
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 16)

                            // Current value bar with gradient
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [
                                        .blue,
                                        isGestureDetected ? .green : .orange
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(
                                    width: CGFloat(gestureValue) * geometry.size.width,
                                    height: 16
                                )
                                .animation(.easeInOut(duration: 0.1), value: gestureValue)

                            // Threshold indicator line (more prominent)
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 3, height: 20)
                                .offset(x: CGFloat(threshold) * geometry.size.width - 1.5)
                                .shadow(color: .red.opacity(0.3), radius: 2, x: 0, y: 0)

                            // Threshold label
                            Text("Target")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                                .background(
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(Color.white)
                                        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
                                )
                                .padding(.horizontal, 3)
                                .padding(.vertical, 1)
                                .offset(
                                    x: max(15, min(geometry.size.width - 30, CGFloat(threshold) * geometry.size.width - 15)),
                                    y: -15
                                )
                        }
                    }
                    .frame(height: 20)
                    
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
        .onChange(of: detector.previewGestureValues) { _, newValues in
            let newValue = newValues[gesture] ?? 0.0

            // Only protect against corruption if we get exactly 0.0 after a very high value (>0.8)
            // This allows natural drops to low baseline values (~0.2-0.3) which are normal for eye gestures
            if newValue == 0.0 && currentGestureValue > 0.8 {
                print("⚠️ GesturePreviewView: Detected suspicious drop to 0.0 for \(gesture.displayName) (was \(currentGestureValue)) - ignoring")
                return
            }

            if newValue != currentGestureValue {
                currentGestureValue = newValue
            }
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
