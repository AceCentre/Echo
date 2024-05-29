//
//  Settings.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 24/05/2024.
//

import Foundation
import SwiftData

@Model
class Settings {
    var showOnboarding: Bool
    
    var currentVocab: Vocabulary?
    
    init(showOnboarding: Bool = true) {
        self.showOnboarding = showOnboarding
    }
}
