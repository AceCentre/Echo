//
//  AccessOptionsArea.swift
// Echo
//
//  Created by Gavin Henderson on 26/06/2024.
//

import Foundation
import SwiftUI
import GameController
import SwiftData

struct AccessOptionsArea: View {
    @Environment(Settings.self) var settings: Settings
        
    var body: some View {
        @Bindable var settingsBindable = settings
        Form {
            Section(content: {
                Toggle(
                    String(
                        localized: "Show on-screen arrows",
                        comment: "Label for toggle for on screen arrows"
                    ),
                    isOn: $settingsBindable.showOnScreenArrows
                )
            }, header: {
                Text("On-screen", comment: "Header for on screen arrow options area")
            })
            
            Section(content: {
                Toggle(
                    String(
                        localized: "Tap and Gesture control",
                        comment: "Toggle for swiping gestures"
                    ),
                    isOn: $settingsBindable.allowSwipeGestures
                )
                
            }, footer: {
                Text(
            """
            Swipe up, down, left or right to control Echo
               • **Tap:** Select the current item
               • **Left to Right:** Select the current item
               • **Right to Left:** Remove the last entered character
               • **Top to Bottom:** Go to the previous item in the list
               • **Bottom to Top:** Go to the next item in the list
            """,
            comment: "A description of all the swiping gestures. Please use the same format including bold text"
                )
            })

            SwitchControlSection()
            GameControllerSection()
            FacialGestureSection()

            // Add some bottom spacing
            Section {
                EmptyView()
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
        .navigationTitle(
            String(
                localized: "Access Options",
                comment: "The navigation title for the access options page"
            )
        )
    }
}
