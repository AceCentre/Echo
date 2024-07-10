//
//  ControllerButton.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 10/07/2024.
//

import Foundation
import GameController

class ControllerButton: Identifiable {
    var internalButton: GCButtonElement?
    var symbolName: String
    var displayName: String
    
    var tapAction: SwitchAction
    var holdAction: SwitchAction
        
    init(displayName: String, symbolName: String, tapAction: SwitchAction, holdAction: SwitchAction) {
        self.displayName = displayName
        self.symbolName = symbolName
        self.tapAction = tapAction
        self.holdAction = holdAction
    }
    
    init(_ button: GCButtonElement, tapAction: SwitchAction, holdAction: SwitchAction) {
        self.internalButton = button
        self.symbolName = internalButton?.sfSymbolsName ?? "button.programmable.square"
        self.displayName = internalButton?.localizedName ?? String(localized: "Unknown Button", comment: "Name of a button when none is given")
        self.tapAction = tapAction
        self.holdAction = holdAction
    }
}
