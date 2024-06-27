//
//  GameController.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 27/06/2024.
//

import Foundation
import SwiftData
import GameController

@Model
class GameController {
    var displayName: String
    var isConnected: Bool

    var buttons: [GameControllerButton]

    init(name: String, buttons: [GameControllerButton]) {
        self.displayName = name
        self.buttons = buttons
        self.isConnected = false
    }
    
    func setupButtons(_ gcController: GCController) {
        var tempButtons: [GameControllerButton] = []
        
        if gcController.gamepad != nil || gcController.extendedGamepad != nil || gcController.microGamepad != nil {
            let upButton = GameControllerButton(
                name: "Up Button",
                symbolName: "arrowshape.up",
                tapAction: .none,
                holdAction: .none
            )
            let downButton = GameControllerButton(
                name: "Down Button",
                symbolName: "arrowshape.down",
                tapAction: .none,
                holdAction: .none
            )
    
            let leftButton = GameControllerButton(
                name: "Left Button",
                symbolName: "arrowshape.left",
                tapAction: .none,
                holdAction: .none
            )
            let rightButton = GameControllerButton(
                name: "Right Button",
                symbolName: "arrowshape.right",
                tapAction: .none,
                holdAction: .none
            )
            
            tempButtons.append(upButton)
            tempButtons.append(downButton)
            tempButtons.append(leftButton)
            tempButtons.append(rightButton)
        }
        
        let input = gcController.input
        
        for internalButton in input.buttons {
            let newButton = GameControllerButton(
                name: internalButton.localizedName ?? String(localized: "Unknown Button", comment: "Name of a button when none is given"),
                symbolName: internalButton.sfSymbolsName ?? "button.programmable.square",
                tapAction: .none,
                holdAction: .none
            )
    
            tempButtons.append(newButton)
        }
        
        self.buttons = tempButtons
    }
}
