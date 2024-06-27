//
//  GameController.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 26/06/2024.
//

import Foundation
import SwiftData
import GameController

@Model
class GameControllerManager {
    var controllers: [GameController]
    
    init(controllers: [GameController]) {
        self.controllers = controllers
    }
    
    func startControllerListeners() {
        self.resetControllers()

        // Listen for controll connect and disconnect events. Reset the controllers list when that happens
        NotificationCenter.default.addObserver(self, selector: #selector(resetControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resetControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }

    @objc
    func resetControllers() {
        // Mark all controllers as disconnected
        for controller in controllers {
            controller.isConnected = false
        }
        
        let gcControllers = GCController.controllers()

        for controller in gcControllers {
            let currentStoredController: GameController? = controllers.first(where: {
                $0.displayName == controller.vendorName
            })

            if let unrwappedCurrentStoredController = currentStoredController {
                unrwappedCurrentStoredController.isConnected = true
            } else {
                let newController = GameController(name: controller.vendorName ?? "Unknown Game Controller", buttons: [])

                newController.setupButtons(controller)
                
                newController.isConnected = true

                controllers.append(newController)
            }
        }
    }
}
