//
//  String.swift
// Echo
//
//  Created by Gavin Henderson on 28/05/2024.
//

import Foundation

public extension Character {
    /// A Boolean value indicating whether the character is an emoji.
    var isEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }

        // Keycap sequences (e.g. 1️⃣, *️⃣, #️⃣)
        if unicodeScalars.contains(where: { $0.value == 0x20E3 }) {
            return true
        }

        // Characters with default emoji presentation (e.g. 😀, 🐶, 🚗)
        if unicodeScalars.contains(where: { $0.properties.isEmojiPresentation }) {
            return true
        }

        // Characters with Variation Selector 16 requesting emoji presentation (e.g. ☀️, ❤️)
        if unicodeScalars.contains(where: { $0.value == 0xFE0F }) && unicodeScalars.contains(where: { $0.properties.isEmoji }) {
            return true
        }

        // Characters in dedicated emoji and dingbat/symbol ranges that have the emoji property
        // (e.g. ✌, ☕, ✈, ❤ even when typed without an explicit variation selector)
        let isSymbolRange = (0x2600...0x27BF).contains(firstScalar.value) || (0x1F000...0x1FAFF).contains(firstScalar.value)
        if firstScalar.properties.isEmoji && isSymbolRange {
            return true
        }

        return false
    }
}

public extension String {
    /**
     Convert a string into a slugified version
     
     For example 'This is an example' -> 'this-is-an-example
     
     Reference: https://danielsaidi.com/blog/2022/05/30/slugify-a-string
     */
    func slugified(
        separator: String = "-",
        allowedCharacters: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
    ) -> String {
        self.lowercased()
            .components(separatedBy: allowedCharacters.inverted)
            .filter { $0 != "" }
            .joined(separator: separator)
    }

    /// Returns a copy of the string with all emoji characters removed and whitespace neatly trimmed.
    var removingEmojis: String {
        let withoutEmojis = self.filter { !$0.isEmoji }
        return withoutEmojis
            .replacingOccurrences(of: "[ \\t]+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Strips emojis from the provided text and neatly trims whitespace.
    static func stripEmojis(from text: String) -> String {
        text.removingEmojis
    }
}
