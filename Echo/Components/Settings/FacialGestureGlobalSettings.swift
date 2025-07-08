//
//  FacialGestureGlobalSettings.swift
//  Echo
//
//  Created by Will Wade on 04/07/2025.
//

import SwiftUI

struct FacialGestureGlobalSettings: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Settings.self) var settings: Settings
    
    var body: some View {
        @Bindable var settingsBindable = settings
        
        NavigationStack {
            Form {
                Section(content: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Short Hold Duration")
                            Spacer()
                            Text("\(String(format: "%.1f", settings.facialGestureShortHoldDuration))s")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $settingsBindable.facialGestureShortHoldDuration,
                            in: 0.3...2.0,
                            step: 0.1
                        )
                        .tint(.blue)
                        
                        Text("Duration for short hold gestures")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Long Hold Duration")
                            Spacer()
                            Text("\(String(format: "%.1f", settings.facialGestureLongHoldDuration))s")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $settingsBindable.facialGestureLongHoldDuration,
                            in: 1.0...5.0,
                            step: 0.1
                        )
                        .tint(.blue)
                        
                        Text("Duration for long hold gestures")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }, header: {
                    Text("Duration Settings", comment: "Header for duration settings section")
                }, footer: {
                    Text("These settings apply to all facial gestures configured with short hold or long hold duration types. Individual gestures can still have their own sensitivity thresholds.", comment: "Footer explaining global duration settings")
                })
                
                Section(content: {
                    Button(action: {
                        resetToDefaults()
                    }) {
                        Text("Reset to Defaults", comment: "Button to reset settings to defaults")
                            .foregroundColor(.red)
                    }
                }, header: {
                    Text("Reset", comment: "Header for reset section")
                })
            }
            .navigationTitle("Global Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetToDefaults() {
        settings.facialGestureShortHoldDuration = 0.8
        settings.facialGestureLongHoldDuration = 2.0
    }
}

#Preview {
    FacialGestureGlobalSettings()
        .environment(Settings())
}
