//
//  AccessOptionsPage.swift
//  Echo
//
//  Created by Gavin Henderson on 04/10/2023.
//

import Foundation
import SwiftUI

struct AccessOptionsPage: View {
    @EnvironmentObject var accessOptions: AccessOptions
    
    @State var showNewSwitchSheet = false
    
    @State var currentSwitch: Switch?
    
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
        }
        .onDisappear {
            accessOptions.save()
        }
        .sheet(isPresented: $showNewSwitchSheet) {
            AddSwitch()
        }
        .sheet(item: $currentSwitch) { currentSwitchObject in
            AddSwitch(
                switchName: currentSwitchObject.name,
                selectedKey: currentSwitchObject.key,
                tapAction: currentSwitchObject.tapAction,
                holdAction: currentSwitchObject.holdAction,
                id: currentSwitchObject.id
            )
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
                                        key: .downArrow,
                                        tapAction: .back,
                                        holdAction: .none
                                    )
                                    self.accessOptions.addSwitch(
                                        name: "Another One",
                                        key: .upArrow,
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
