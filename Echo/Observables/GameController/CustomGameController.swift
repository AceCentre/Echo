//
//  CustomGameController.swift
//  Echo
//
//  Created by Gavin Henderson on 18/12/2023.
//

import Foundation
import GameController

class CustomGameController: Identifiable {
    var internalController: GCController
    var id: String
    var buttons: [ControllerButton]
    
    var left: Float = 0
    var right: Float = 0
    var up: Float = 0
    var down: Float = 0
    
    var responder: ((ControllerButton, Bool) -> Void)?
    
    var displayName: String {
        return internalController.vendorName ?? String(localized: "Unknown Controller", comment: "Name of the controller if none is givens")
    }
    
    func save() {
        var tapButtonMap: [String: Action] = [:]
        var holdButtonMap: [String: Action] = [:]
        
        for button in buttons {
            tapButtonMap.updateValue(button.tapAction, forKey: button.displayName)
            holdButtonMap.updateValue(button.holdAction, forKey: button.displayName)
        }
        
        let jsonEncoder = JSONEncoder()
        
        do {
            let tapData = try jsonEncoder.encode(tapButtonMap)
            let holdData = try jsonEncoder.encode(holdButtonMap)
            UserDefaults.standard.set(tapData, forKey: "\(id)-tap-controller")
            UserDefaults.standard.set(holdData, forKey: "\(id)-hold-controller")
        } catch {
            print("Failed to persist your settings")
        }
    }
    
    func load() {
        var tapButtonMap: [String: Action] = [:]
        var holdButtonMap: [String: Action] = [:]
        
        if let tapData = UserDefaults.standard.data(forKey: "\(id)-tap-controller") {
            do {
                let decoder = JSONDecoder()
                tapButtonMap = try decoder.decode([String: Action].self, from: tapData)
            } catch {
                print("Failed to load your settings")
            }
        }
        
        if let holdData = UserDefaults.standard.data(forKey: "\(id)-hold-controller") {
            do {
                let decoder = JSONDecoder()
                holdButtonMap = try decoder.decode([String: Action].self, from: holdData)
            } catch {
                print("Failed to load your settings")
            }
        }
        
        for button in buttons {
            let loadedTap = tapButtonMap[button.displayName]
            let loadedHold = holdButtonMap[button.displayName]
            
            if let tap = loadedTap {
                button.tapAction = tap
            } else {
                if let buttonDefaults = ButtonDefaults(rawValue: button.displayName) {
                    button.tapAction = buttonDefaults.tapAction
                } else {
                    print("No default actions for", button.displayName)
                    button.tapAction = .none
                }
            }
            
            if let hold = loadedHold {
                button.holdAction = hold
            } else {
                if let buttonDefaults = ButtonDefaults(rawValue: button.displayName) {
                    button.holdAction = buttonDefaults.holdAction
                } else {
                    print("No default actions for", button.displayName)
                    button.holdAction = .none
                }
            }
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    init(_ controller: GCController) {
        internalController = controller
        id = controller.vendorName ?? "no-name"
        buttons = []
        
        if controller.gamepad != nil || controller.extendedGamepad != nil || controller.microGamepad != nil {
            let upButton = ControllerButton(
                displayName: "Up Button",
                symbolName: "arrowshape.up",
                tapAction: .none,
                holdAction: .none
            )
            buttons.append(upButton)
            
            let downButton = ControllerButton(
                displayName: "Down Button",
                symbolName: "arrowshape.down",
                tapAction: .none,
                holdAction: .none
            )
            buttons.append(downButton)
            
            let leftButton = ControllerButton(
                displayName: "Left Button",
                symbolName: "arrowshape.left",
                tapAction: .none,
                holdAction: .none
            )
            buttons.append(leftButton)
            
            let rightButton = ControllerButton(
                displayName: "Right Button",
                symbolName: "arrowshape.right",
                tapAction: .none,
                holdAction: .none
            )
            buttons.append(rightButton)
            
            let dPadHandler: GCControllerDirectionPadValueChangedHandler = { button, _, _ in                
                if let unwrappedResponser = self.responder {
                    if self.down != button.down.value {
                        unwrappedResponser(downButton, button.down.value != 0)
                        self.down = button.down.value
                    }
                    
                    if self.up != button.up.value {
                        unwrappedResponser(upButton, button.up.value != 0)
                        self.up = button.up.value
                    }
                    
                    if self.left != button.left.value {
                        unwrappedResponser(leftButton, button.left.value != 0)
                        self.left = button.left.value
                    }
                    
                    if self.right != button.right.value {
                        unwrappedResponser(rightButton, button.right.value != 0)
                        self.right = button.right.value
                    }
                }
            }
            
            if let gamepad = controller.gamepad {
                gamepad.dpad.valueChangedHandler = dPadHandler
            }

            if let extendedGamepad = controller.extendedGamepad {
                extendedGamepad.dpad.valueChangedHandler = dPadHandler
            }

            if let microGamepad = controller.microGamepad {
                microGamepad.dpad.valueChangedHandler = dPadHandler
            }
            
        }
        
        let input = controller.input

        for button in input.buttons {
            let newButton = ControllerButton(
                button,
                tapAction: .none,
                holdAction: .none
            )
                        
            buttons.append(newButton)
        }

        for button in buttons {
            button.internalButton?.pressedInput.pressedDidChangeHandler = { (_: GCPhysicalInputElement, _: GCPressedStateInput, pressed: Bool) in
                if let unwrappedResponser = self.responder {
                    unwrappedResponser(button, pressed)
                }
            }
        }
        
        self.load()
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}
