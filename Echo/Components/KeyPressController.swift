//
//  KeyPressController.swift
//  Echo
//
//  Created by Gavin Henderson on 13/10/2023.
//

import Foundation
import SwiftUI

enum KeyStage {
    case unpressed, pressed, held
}

/***
 This whole view is a bit of a hack but it works nicely
 
 For every registered switch it renders a button with a keyboard shortcut. It doesn't visually display anything
 It then triggers the correct action for the given switch
 */
struct KeyPressController: View {
    @EnvironmentObject var items: ItemsList
    @EnvironmentObject var accessOptions: AccessOptions
    @EnvironmentObject var analytics: Analytics
    
    @FocusState var focused
        
    // This method does complain that 'Publishing changes from within view updates is not allowed,
    // this will cause undefined behavior.'
    // Im not sure why because im changing it in an onKeyPress function not a view update
    // However, because we dont display keyMap we shouldn't get any 'undefined behaviour'
    @State var keyMap: [UIKeyboardHIDUsage: KeyStage] = [:]
    @State var workItemsMap: [UIKeyboardHIDUsage: DispatchWorkItem] = [:]
    
    func doAction(action: Action) {
        switch action {
        case .none:
            print("No action")
        case .next:
            items.next(userInteraction: true)
        case .back:
            items.back(userInteraction: true)
        case .fast:
            items.startFastScan()
        case .clear:
            items.clear(userInteraction: true)
        case .delete:
            items.backspace(userInteraction: true)
        case .select:
            items.select(userInteraction: true)
        case .startScanning:
            items.startScanningOnKeyPress()
        }
    }
    
    var body: some View {
        KeyboardPressDetectorView { press in
            guard let currentKeyCode = press.key?.keyCode else {
                return
            }
            
            // We only want to capture buttons that the user has specifed
            guard let currentSwitch = accessOptions.listOfSwitches.first(where: { $0.key == currentKeyCode }) else {
                return
            }
            
            if press.phase == .began {
                analytics.userInteraction(type: "SwitchPress", extraInfo: keyToDisplay(currentKeyCode))
            }
            
            let currentKeyStage = keyMap[currentKeyCode] ?? .unpressed
            
            // Deal with keydown event
            if press.phase == .began {
                self.keyMap.updateValue(.pressed, forKey: currentKeyCode)
                
                // Cancel any previous work items now we have a new keypress
                let lastWorkItem = self.workItemsMap[currentKeyCode]
                lastWorkItem?.cancel()
                
                // Shedule hold callback
                let newWorkItem = DispatchWorkItem(block: {
                    let keyStage = keyMap[currentKeyCode] ?? .unpressed
                                            
                    if keyStage == .pressed {
                        self.keyMap.updateValue(.held, forKey: currentKeyCode)
                        
                        doAction(action: currentSwitch.holdAction)
                    }
                })
                
                let timeInterval = 1.0
                self.workItemsMap.updateValue(newWorkItem, forKey: currentKeyCode)
                DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: newWorkItem)
            }
            
            // When the key is up we need to do our action
            if press.phase == .ended {
                // Normal length press
                if currentKeyStage == .pressed {
                    doAction(action: currentSwitch.tapAction)
                }
                
                // The key was held for longer than the threshold
                if currentKeyStage == .held {
                    if currentSwitch.holdAction == .fast {
                        items.stopFastScan()
                    }
                }
                
                self.keyMap.updateValue(.unpressed, forKey: currentKeyCode)
            }
            
            return
        }
    }
}
