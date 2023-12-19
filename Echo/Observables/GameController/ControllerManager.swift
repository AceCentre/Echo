//
//  ControllerManager.swift
//  Echo
//
//  Created by Gavin Henderson on 18/12/2023.
//

import Foundation
import GameController

class ControllerManager: ObservableObject {
    @Published var controllers: [CustomGameController] = []

    var itemsList: ItemsList?
    var analytics: Analytics?
    
    var keyMap: [String: KeyStage] = [:]
    var workItemsMap: [String: DispatchWorkItem] = [:]
    
    init() {
        self.resetControllers()
        
        // Listen for controll connect and disconnect events. Reset the controllers list when that happens
        NotificationCenter.default.addObserver(self, selector: #selector(resetControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    func loadItems(_ itemsList: ItemsList) {
        self.itemsList = itemsList
    }
    
    func loadAnalytics(_ analytics: Analytics) {
        self.analytics = analytics
    }
    
    @objc
    func resetControllers() {
        self.controllers = GCController.controllers().map { controller in
            return CustomGameController(controller)
        }
        
        for controller in controllers {
            controller.responder = { (button: ControllerButton, pressed: Bool) in
                if pressed {
                    self.analytics?.gamePadButtonPress(controllerName: controller.displayName, buttonName: button.displayName)
                }
                
                let buttonName = "\(controller.displayName)-\(button.displayName)"
                
                let currentKeyStage = self.keyMap[buttonName] ?? .unpressed

                if pressed {
                    self.keyMap.updateValue(.pressed, forKey: buttonName)
                    
                    // Cancel any previous work items now we have a new keypress
                    let lastWorkItem = self.workItemsMap[buttonName]
                    lastWorkItem?.cancel()
                    
                    // Shedule hold callback
                    let newWorkItem = DispatchWorkItem(block: {
                        let keyStage = self.keyMap[buttonName] ?? .unpressed
                                                
                        if keyStage == .pressed {
                            self.keyMap.updateValue(.held, forKey: buttonName)
                            
                            self.itemsList?.doAction(action: button.holdAction)
                        }
                    })
                    
                    let timeInterval = 1.0
                    self.workItemsMap.updateValue(newWorkItem, forKey: buttonName)
                    DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: newWorkItem)
                }
                
                // When the key is up we need to do our action
                if !pressed {
                    // Normal length press
                    if currentKeyStage == .pressed {
                        self.itemsList?.doAction(action: button.tapAction)
                    }
                    
                    // The key was held for longer than the threshold
                    if currentKeyStage == .held {
                        if button.holdAction == .fast {
                            self.itemsList?.stopFastScan()
                        }
                    }
                    
                    self.keyMap.updateValue(.unpressed, forKey: buttonName)
                }
            }
        }
    }
}
