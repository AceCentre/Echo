//
//  LoggingSettingsView.swift
//  Echo
//
//  Created by Augment Agent on 17/07/2025.
//

import SwiftUI

struct LoggingSettingsView: View {
    @State private var selectedLogLevel = EchoLogger.minimumLogLevel
    @State private var emojiEnabled = EchoLogger.useEmoji
    @State private var sourceInfoEnabled = EchoLogger.includeSourceInfo
    
    var body: some View {
        Form {
            Section(header: Text("Logging Configuration")) {
                Picker("Log Level", selection: $selectedLogLevel) {
                    ForEach(EchoLogger.LogLevel.allCases, id: \.self) { level in
                        Text("\(level.emoji) \(level.name)")
                            .tag(level)
                    }
                }
                .onChange(of: selectedLogLevel) { _, newValue in
                    EchoLogger.setLogLevel(newValue)
                }
                
                Toggle("Show Emoji Prefixes", isOn: $emojiEnabled)
                    .onChange(of: emojiEnabled) { _, newValue in
                        EchoLogger.setEmojiEnabled(newValue)
                    }
                
                Toggle("Show Source Info", isOn: $sourceInfoEnabled)
                    .onChange(of: sourceInfoEnabled) { _, newValue in
                        EchoLogger.setSourceInfoEnabled(newValue)
                    }
            }
            
            Section(header: Text("Log Level Guide")) {
                VStack(alignment: .leading, spacing: 8) {
                    LogLevelRow(level: .debug, description: "Detailed debugging information")
                    LogLevelRow(level: .info, description: "General information messages")
                    LogLevelRow(level: .warning, description: "Warning messages")
                    LogLevelRow(level: .error, description: "Error messages")
                    LogLevelRow(level: .critical, description: "Critical system errors")
                }
            }
            
            Section(header: Text("Test Logging")) {
                Button("Test All Log Levels") {
                    testAllLogLevels()
                }
            }
            
            #if DEBUG
            Section(header: Text("Current Configuration")) {
                Text(EchoLogger.getConfiguration())
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            #endif
        }
        .navigationTitle("Logging Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func testAllLogLevels() {
        EchoLogger.debug("This is a debug message")
        EchoLogger.info("This is an info message")
        EchoLogger.warning("This is a warning message")
        EchoLogger.error("This is an error message")
        EchoLogger.critical("This is a critical message")
        
        // Test category-specific logging
        EchoLogger.voice("Voice system test message")
        EchoLogger.facialGesture("Facial gesture test message")
        EchoLogger.eyeTracking("Eye tracking test message")
    }
}

struct LogLevelRow: View {
    let level: EchoLogger.LogLevel
    let description: String
    
    var body: some View {
        HStack {
            Text(level.emoji)
            Text(level.name)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.primary)
            Text("-")
                .foregroundColor(.secondary)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        LoggingSettingsView()
    }
}
