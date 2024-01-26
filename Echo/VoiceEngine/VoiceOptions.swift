//
//  VoiceOptions.swift
//  Echo
//
//  Created by Gavin Henderson on 18/01/2024.
//

class VoiceOptions: Codable {
    var voiceId: String
    var rate: Float
    var pitch: Float
    var volume: Float
        
    init() {
        self.voiceId = ""
        self.rate = 50
        self.pitch = 25
        self.volume = 100
    }
    
    init(
        voiceId: String,
        rate: Float,
        pitch: Float,
        volume: Float
    ) {
        self.voiceId = voiceId
        self.rate = rate
        self.pitch = pitch
        self.volume = volume
    }
    
    init(_ voiceId: String) {
        self.voiceId = voiceId
        self.rate = 50
        self.pitch = 25
        self.volume = 100
    }
}
