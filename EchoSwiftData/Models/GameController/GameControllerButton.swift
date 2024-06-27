//
//  GameControllerButton.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 27/06/2024.
//

import Foundation
import SwiftData

@Model
class GameControllerButton {
    var name: String
    var symbolName: String
    var tapAction: SwitchAction
    var holdAction: SwitchAction
    var controller: GameController?
    
    init(
        name: String,
        symbolName: String,
        tapAction: SwitchAction,
        holdAction: SwitchAction
    ) {
        self.name = name
        self.symbolName = symbolName
        self.tapAction = tapAction
        self.holdAction = holdAction
    }
}
