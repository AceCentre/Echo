//
//  KeyPressController.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 09/07/2024.
//

import Foundation
import SwiftUI
import SwiftData

enum KeyStage {
    case unpressed, pressed, held
}

/***
 This whole view is a bit of a hack but it works nicely
 
 For every registered switch it renders a button with a keyboard shortcut. It doesn't visually display anything
 It then triggers the correct action for the given switch
 */
struct KeyPressController: View {
    @ObservedObject var mainCommunicationPageState: MainCommunicationPageState
    
    @Query var switches: [Switch]
    
    // This method does complain that 'Publishing changes from within view updates is not allowed,
    // this will cause undefined behavior.'
    // Im not sure why because im changing it in an onKeyPress function not a view update
    // However, because we dont display keyMap we shouldn't get any 'undefined behaviour'
    @State var keyMap: [UIKeyboardHIDUsage: KeyStage] = [:]
    @State var workItemsMap: [UIKeyboardHIDUsage: DispatchWorkItem] = [:]
    
    var body: some View {
        KeyboardPressDetectorView { press in
            guard let currentKeyCode = press.key?.keyCode else {
                return
            }
            
            // We only want to capture buttons that the user has specifed
            guard let currentSwitch = switches.first(where: { $0.key == currentKeyCode }) else {
                return
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
                        
                        mainCommunicationPageState.doAction(action: currentSwitch.holdAction)
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
                    mainCommunicationPageState.doAction(action: currentSwitch.tapAction)
                }
                
                // The key was held for longer than the threshold
                if currentKeyStage == .held {
                    if currentSwitch.holdAction == .fast {
                        mainCommunicationPageState.stopFastScan()
                    }
                }
                
                self.keyMap.updateValue(.unpressed, forKey: currentKeyCode)
            }
            
            return
        }
    }
}
