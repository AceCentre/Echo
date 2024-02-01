//
//  AccessOptionsPage.swift
//  Echo
//
//  Created by Gavin Henderson on 04/10/2023.
//

import Foundation
import SwiftUI
import GameController

struct AccessOptionsPage: View {
    @EnvironmentObject var accessOptions: AccessOptions
    @EnvironmentObject var controllerManager: ControllerManager
    
    @State var showNewSwitchSheet = false
    
    @State var currentSwitch: Switch?
    
    @State var currentController: CustomGameController?
        
    var body: some View {
        Form {
            Section(content: {
                Toggle(
                    String(
                        localized: "Show on-screen arrows",
                        comment: "Label for toggle for on screen arrows"
                    ),
                    isOn: $accessOptions.showOnScreenArrows
                )
            }, header: {
                Text("On-screen", comment: "Header for on screen arrow options area")
            })
            
            Section(content: {
                Toggle(
                    String(
                        localized: "Swiping gestures",
                        comment: "Toggle for swiping gestures"
                    ),
                    isOn: $accessOptions.allowSwipeGestures
                )
                
            }, footer: {
                Text(
            """
            Swipe up, down, left or right to control Echo
               • **Right:** Select the current item
               • **Down:** Go to the next item in the list
               • **Left:** Remove the last entered character
               • **Up:** Go to the previous item in the list
            """,
            comment: "A description of all the swiping gestures. Please use the same format including bold text"
                )
            })
            
            Section(content: {
                Toggle(
                    String(
                        localized: "Switch Control",
                        comment: "Label for toggle to turn switch control off and on"
                    ),
                    isOn: $accessOptions.enableSwitchControl
                )
                
                ForEach(accessOptions.listOfSwitches) { switchForButton in
                    Button(action: {
                        currentSwitch = switchForButton
                    }, label: {
                        HStack {
                            Text(switchForButton.name)
                            Spacer()
                            Text(keyToDisplay(switchForButton.key))
                                .foregroundStyle(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                    })
                }
                Button(action: {
                    showNewSwitchSheet.toggle()
                }, label: {
                    Label(
                        String(
                            localized: "Add Switch",
                            comment: "Button label to add a new switch to the list"
                        ),
                        systemImage: "plus.circle.fill"
                    )
                })
            }, footer: {
                Text(
                """
                Control Echo using switch presses to perform actions. Add new switches and change what they trigger.
                """,
                comment: "Footer description describing what switch access is"
                )
            })
            
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
        .onDisappear {
            accessOptions.save()
        }
        AddSwitchSheet(showNewSwitchSheet: $showNewSwitchSheet, currentSwitch: $currentSwitch)
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
        
        .navigationTitle(
            String(
                localized: "Access Options",
                comment: "The navigation title for the access options page"
            )
        )
    }
}

private struct PreviewWrapper: View {
    @StateObject var accessOptions: AccessOptions = AccessOptions()
    
    var body: some View {
        NavigationStack {
            Text("Main Page")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        navigationDestination(isPresented: .constant(true), destination: {
                            AccessOptionsPage()
                                .environmentObject(accessOptions)
                                .onAppear {
                                    self.accessOptions.addSwitch(
                                        name: "Demo Switch",
                                        key: .keyboardDownArrow,
                                        tapAction: .back,
                                        holdAction: .none
                                    )
                                    self.accessOptions.addSwitch(
                                        name: "Another One",
                                        key: .keyboardUpArrow,
                                        tapAction: .next,
                                        holdAction: .none
                                    )
                                }
                        })
                        
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct AccessOptionsPage_Previews: PreviewProvider {
    
    static var previews: some SwiftUI.View {
        PreviewWrapper().preferredColorScheme(.light)
        
    }
}
