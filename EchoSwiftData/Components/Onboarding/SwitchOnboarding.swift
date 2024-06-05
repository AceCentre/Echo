//
//  SwitchOnboarding.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 31/05/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct SwitchOnboarding: View {
    @State var showNewSwitchSheet = false
    @State var currentSwitch: Switch?

    @Environment(Settings.self) var settings: Settings

    @Query var switches: [Switch]
    
    var body: some View {
        @Bindable var settingsBindable = settings
        VStack {
            VStack {
                Spacer()
                ZStack {
                    Image(systemName: "button.horizontal.top.press")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(Color("aceBlue"))
                    if !settings.enableSwitchControl {
                        Image("Slash")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .accessibilityLabel(String(
                                localized: "A slash to indicate disabled",
                                comment: "Accessibility label for slash"
                            ))
                    }
                }
                Spacer()
            }
            
            BottomText(
                topText: AttributedString(
                    localized: "Switch Control",
                    comment: "Header for switch control in onboarding page"
                ),
                bottomText: AttributedString(
                    localized: "Control Echo using switch presses to perform actions. Add new switches and change what they trigger.",
                    comment: "Description describing what switch access is"
                )
            )
            Form {
                Section(content: {
                    Toggle(
                        String(
                            localized: "Switch Control",
                            comment: "Label for toggle to turn switch control off and on"
                        ),
                        isOn: $settingsBindable.enableSwitchControl
                    )
                    
                    ForEach(switches) { currentLoopSwitch in
                        Button(action: {
                            currentSwitch = currentLoopSwitch
                            showNewSwitchSheet.toggle()
                        }, label: {
                            HStack {
                                Text(currentLoopSwitch.name)
                                Spacer()
                                Text(keyToDisplay(currentLoopSwitch.key))
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
                })
                
            }
            .scrollContentBackground(.hidden)
            AddSwitchSheet(
                showNewSwitchSheet: $showNewSwitchSheet, currentSwitch: $currentSwitch
            )
        }
        
    }
}
