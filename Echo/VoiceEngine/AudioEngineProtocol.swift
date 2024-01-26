//
//  AudioEngineProtocol.swift
//  Echo
//
//  Created by Gavin Henderson on 18/01/2024.
//

import Foundation

protocol AudioEngineProtocol {
    func stop()
    func speak(text: String, voiceOptions: VoiceOptions, cb: (() -> Void)?)
}
