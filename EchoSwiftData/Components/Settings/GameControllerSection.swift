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

struct ControllerEditor: View {
    @Binding var currentGameController: GameController?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationStack {
            if let unwrappedGameController = currentGameController {
                @Bindable var bindableGameController = unwrappedGameController
                Form {
                    ForEach(bindableGameController.buttons.sorted { $0.name < $1.name }) { controllerButton in
                        Section {
                            Label(controllerButton.name, systemImage: controllerButton.symbolName)
                            
                            @Bindable var bindableButton = controllerButton
                            
                            ActionPicker(
                                label: String(
                                    localized: "Single Tap",
                                    comment: "The label that is shown next to the single tap action"
                                ),
                                actions: SwitchAction.tapCases,
                                actionChange: { newAction in
                                    bindableButton.tapAction = newAction
                                },
                                actionState: controllerButton.tapAction
                            )
                            
                            ActionPicker(
                                label: String(
                                    localized: "Hold",
                                    comment: "The label that is shown next to the single hold action"
                                ),
                                actions: SwitchAction.holdCases,
                                actionChange: { newAction in
                                    bindableButton.holdAction = newAction
                                },
                                actionState: controllerButton.holdAction
                            )
                            
                        }
                    }
                    
                }
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text(
                                "Save",
                                comment: "The save toolbar button when saving controller mapping"
                            )
                        })
                    }
                }
                .navigationTitle(bindableGameController.displayName)
            }
        }
        
        
    }
}


struct GameControllerSection: View {
    @Environment(GameControllerManager.self) var gameControllerManager: GameControllerManager
    
    @State var showGameControllerSheet = false
    @State var currentGameController: GameController?
    
    var body: some View {
        Section(content: {
            ForEach(gameControllerManager.controllers) { controller in
                Button(action: {
                    currentGameController = controller
                    showGameControllerSheet.toggle()
                }, label: {
                    HStack {
                        Circle()
                            .fill(controller.isConnected ? .green : .red)
                            .frame(width: 15, height: 15)
                        Label(controller.displayName, systemImage: "gamecontroller.fill")
                        Spacer()
                        Text("Map Buttons", comment: "The help text on the controller button")
                            .foregroundStyle(.gray)
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                })
            }
            .sheet(isPresented: $showGameControllerSheet) {
                ControllerEditor(
                    currentGameController: $currentGameController
                )
            }
            if gameControllerManager.controllers.isEmpty {
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

