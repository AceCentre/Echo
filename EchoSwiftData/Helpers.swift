//
//  Helpers.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation
import UIKit

func getLanguageAndRegion(_ givenLocale: String) -> String {
    let currentLocale: Locale = .current
    return currentLocale.localizedString(forIdentifier: givenLocale) ?? "Unknown"
}

func getLanguage(_ givenLocale: String) -> String {
    let currentLocale: Locale = .current
    return currentLocale.localizedString(forLanguageCode: givenLocale) ?? "Unknown"
}

func keyToDisplay(_ key: UIKeyboardHIDUsage?) -> String {
    return "Key: \(key?.description ?? "UNKNOWN")"
}