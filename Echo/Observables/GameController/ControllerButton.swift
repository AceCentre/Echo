//
//  ControllerButton.swift
//  Echo
//
//  Created by Gavin Henderson on 18/12/2023.
//

import Foundation
import GameController

class ControllerButton: Identifiable {
    var internalButton: GCButtonElement?
    var symbolName: String
    var displayName: String
    
    var tapAction: Action
    var holdAction: Action
        
    init(displayName: String, symbolName: String, tapAction: Action, holdAction: Action) {
        self.displayName = displayName
        self.symbolName = symbolName
        self.tapAction = tapAction
        self.holdAction = holdAction
    }
    
    init(_ button: GCButtonElement, tapAction: Action, holdAction: Action) {
        self.internalButton = button
        self.symbolName = internalButton?.sfSymbolsName ?? "button.programmable.square"
        self.displayName = internalButton?.localizedName ?? String(localized: "Unknown Button", comment: "Name of a button when none is given")
        self.tapAction = tapAction
        self.holdAction = holdAction
    }
}

