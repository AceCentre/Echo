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
    
    var cueVoice: Voice?
    var speakingVoice: Voice?
    
    var splitAudio: Bool
    var cueDirection: AudioDirection
    var speakDirection: AudioDirection
    
    init(showOnboarding: Bool = true) {
        self.showOnboarding = showOnboarding
        
        self.splitAudio = false
        self.cueDirection = .left
        self.speakDirection = .right
    }
}
