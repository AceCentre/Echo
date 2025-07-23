//
//  Helpers.swift
// Echo
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation
import UIKit
import os.log

func getLanguageAndRegion(_ givenLocale: String) -> String {
    if givenLocale == "pv" {
        return "Personal Voice(s)"
    }
    
    let currentLocale: Locale = .current
    return currentLocale.localizedString(forIdentifier: givenLocale) ?? "Unknown"
}

func getLanguage(_ givenLocale: String) -> String {
    if givenLocale == "pv" {
        return "Personal Voice(s)"
    }
    
    let currentLocale: Locale = .current
    return currentLocale.localizedString(forLanguageCode: givenLocale) ?? "Unknown"
}

func keyToDisplay(_ key: UIKeyboardHIDUsage?) -> String {
    return "Key: \(key?.description ?? "UNKNOWN")"
}

// MARK: - Logging System

/// Centralized logging system for Echo app with configurable log levels
class EchoLogger {

    /// Log levels matching Python's logging levels
    enum LogLevel: Int, CaseIterable {
        case debug = 10
        case info = 20
        case warning = 30
        case error = 40
        case critical = 50

        var name: String {
            switch self {
            case .debug: return "DEBUG"
            case .info: return "INFO"
            case .warning: return "WARNING"
            case .error: return "ERROR"
            case .critical: return "CRITICAL"
            }
        }

        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }

        var emoji: String {
            switch self {
            case .debug: return "🐛"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .critical: return "🚨"
            }
        }
    }

    /// Log categories for different parts of the app
    enum Category: String, CaseIterable {
        case voice = "🔊"
        case facialGesture = "🎯"
        case eyeTracking = "👁️"
        case gameController = "🎮"
        case database = "💾"
        case ui = "📱"
        case general = "📝"

        var subsystem: String {
            return "org.acecentre.Echo"
        }

        var osLog: OSLog {
            return OSLog(subsystem: subsystem, category: self.rawValue)
        }
    }

    /// Current minimum log level - only logs at this level or higher will be shown
    static var minimumLogLevel: LogLevel = {
        #if DEBUG
        return .warning  // Only show warnings and errors in debug builds (reduced verbosity)
        #else
        return .info   // Show info and above in release builds
        #endif
    }()

    /// Whether to use emoji prefixes (can be disabled for cleaner logs)
    static var useEmoji: Bool = true

    /// Whether to include file/function/line info in logs
    static var includeSourceInfo: Bool = {
        #if DEBUG
        return false  // Disable detailed source info for cleaner logs
        #else
        return false
        #endif
    }()

    // MARK: - Main Logging Methods

    static func debug(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, category: category, file: file, function: function, line: line)
    }

    static func info(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, category: category, file: file, function: function, line: line)
    }

    static func warning(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, category: category, file: file, function: function, line: line)
    }

    static func error(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, category: category, file: file, function: function, line: line)
    }

    static func critical(_ message: String, category: Category = .general, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .critical, message: message, category: category, file: file, function: function, line: line)
    }

    // MARK: - Core Logging Implementation

    private static func log(level: LogLevel, message: String, category: Category, file: String, function: String, line: Int) {
        // Check if this log level should be shown
        guard level.rawValue >= minimumLogLevel.rawValue else { return }

        let fileName = URL(fileURLWithPath: file).lastPathComponent

        var logMessage = message

        // Add emoji prefix if enabled
        if useEmoji {
            logMessage = "\(category.rawValue) \(logMessage)"
        }

        // Add source info if enabled
        if includeSourceInfo {
            logMessage = "[\(fileName):\(line) \(function)] \(logMessage)"
        }

        // Use os_log for better performance and integration with Console.app
        os_log("%{public}@", log: category.osLog, type: level.osLogType, logMessage)

        // Disable duplicate print() output to reduce log verbosity
        // #if DEBUG
        // print("\(level.emoji) \(level.name): \(logMessage)")
        // #endif
    }

    // MARK: - Configuration Methods

    /// Set the minimum log level at runtime
    static func setLogLevel(_ level: LogLevel) {
        minimumLogLevel = level
        info("Log level set to \(level.name)", category: .general)
    }

    /// Enable/disable emoji prefixes
    static func setEmojiEnabled(_ enabled: Bool) {
        useEmoji = enabled
    }

    /// Enable/disable source info (file:line function)
    static func setSourceInfoEnabled(_ enabled: Bool) {
        includeSourceInfo = enabled
    }

    /// Get current configuration as a string
    static func getConfiguration() -> String {
        return """
        Echo Logger Configuration:
        - Minimum Level: \(minimumLogLevel.name)
        - Emoji Enabled: \(useEmoji)
        - Source Info: \(includeSourceInfo)
        """
    }
}

// MARK: - Convenience Extensions

extension EchoLogger {
    /// Log voice-related messages
    static func voice(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: level, message: message, category: .voice, file: file, function: function, line: line)
    }

    /// Log facial gesture messages
    static func facialGesture(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: level, message: message, category: .facialGesture, file: file, function: function, line: line)
    }

    /// Log eye tracking messages
    static func eyeTracking(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: level, message: message, category: .eyeTracking, file: file, function: function, line: line)
    }

    /// Log game controller messages
    static func gameController(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: level, message: message, category: .gameController, file: file, function: function, line: line)
    }

    /// Log database messages
    static func database(_ message: String, level: LogLevel = .debug, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: level, message: message, category: .database, file: file, function: function, line: line)
    }
}
