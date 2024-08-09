//
//  SwitchControlSection.swift
// Echo
//
//  Created by Gavin Henderson on 26/06/2024.
//

import Foundation
import SwiftData
import SwiftUI

struct SwitchControlSection: View {
    @Environment(Settings.self) var settings: Settings
    
    @Query var switches: [Switch]

    @State var showNewSwitchSheet = false
    @State var currentSwitch: Switch?
    
    var body: some View {
        @Bindable var settingsBindable = settings
        Section(content: {
            ZStack {
                AddSwitchSheet(
                    showNewSwitchSheet: $showNewSwitchSheet, currentSwitch: $currentSwitch
                )
                Toggle(
                    String(
                        localized: "Switch Control",
                        comment: "Label for toggle to turn switch control off and on"
                    ),
                    isOn: $settingsBindable.enableSwitchControl
                )
            }
            
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
                currentSwitch = nil
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
}
