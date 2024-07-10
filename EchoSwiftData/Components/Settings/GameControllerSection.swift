//
//  GameControllerSection.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 26/06/2024.
//

import Foundation
import SwiftData
import SwiftUI
import GameController

struct ControllerButtonSection: View {
    @State var holdAction: SwitchAction
    @State var tapAction: SwitchAction
    var button: ControllerButton
    
    var body: some View {
        ActionPicker(
            label: String(
                localized: "Single Tap",
                comment: "The label that is shown next to the single tap action"
            ),
            actions: SwitchAction.tapCases,
            actionChange: { newAction in
                tapAction = newAction
            },
            actionState: tapAction
        )
        
        ActionPicker(
            label: String(
                localized: "Hold",
                comment: "The label that is shown next to the single hold action"
            ),
            actions: SwitchAction.holdCases,
            actionChange: { newAction in
                holdAction = newAction
            },
            actionState: holdAction
        )
        .onChange(of: holdAction) {
            button.holdAction = holdAction
        }
        .onChange(of: tapAction) {
            button.tapAction = tapAction
        }
    }
}


struct GameControllerSection: View {
    @EnvironmentObject var controllerManager: ControllerManager
    @State var currentController: CustomGameController?
        
    var body: some View {
        Section(content: {
            ForEach(controllerManager.controllers, id: \.id) { controller in
                Button(action: {
                    currentController = controller
                }, label: {
                    HStack {
                        Label(controller.displayName, systemImage: "gamecontroller.fill")
                        Spacer()
                        Text("Map Buttons", comment: "The help text on the controller button")
                            .foregroundStyle(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                })
            }
            .sheet(item: $currentController) { currentControllerObject in
                NavigationStack {
                    Form {
                        ForEach(currentControllerObject.buttons, id: \.id) { button in
                            Section {
                                Label(button.displayName, systemImage: button.symbolName)
                                ControllerButtonSection(
                                    holdAction: button.holdAction,
                                    tapAction: button.tapAction,
                                    button: button
                                )
                            }
            
                        }
                        
                    }
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                currentController = nil
                            }, label: {
                                Text(
                                    "Save",
                                    comment: "The save toolbar button when saving controller mapping"
                                )
                            })
                        }
                    }
                    .navigationTitle(currentControllerObject.displayName)
                }
                .onDisappear {
                    currentControllerObject.save()
                }
            }

            if controllerManager.controllers.isEmpty {
                Text(
                    "No game controller connect to device. Please connect a controller to access these settings",
                    comment: "Notification of no game controllers connected"
                )
            }
        }, header: {
            Text("Game Controllers", comment: "Header for game controller settings area")
        }, footer: {
            Text("Use a game controller to control Echo", comment: "Footer for game controller settings area")
        })
        
    }
    
}

