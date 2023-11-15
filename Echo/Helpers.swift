//
//  Helpers.swift
//  Echo
//
//  Created by Gavin Henderson on 03/10/2023.
//

import Foundation
import SwiftUI

func getLanguageAndRegion(_ givenLocale: String) -> String {
    let currentLocale: Locale = .current
    return currentLocale.localizedString(forIdentifier: givenLocale) ?? "Unknown"
}

func getLanguage(_ givenLocale: String) -> String {
    let currentLocale: Locale = .current
    return currentLocale.localizedString(forLanguageCode: givenLocale) ?? "Unknown"
}

func getNumberOfWords(_ text: String) -> Int {
    return text.components(separatedBy: " ").count
}

func getAverageWordLength(_ text: String) -> Int {
    let wordLength = text.components(separatedBy: " ").map { x in
        return x.count
    }
    
    let sumOfChars = wordLength.reduce(0, +)

    let average = Double(sumOfChars) / Double(wordLength.count)
    
    return Int(average.rounded())
}

func getTotalUtteranceLength(_ text: String) -> Int {
    return text.count
}

func keyToDisplay(_ key: UIKeyboardHIDUsage) -> String {
    return "Key: \(key.description)"
}
