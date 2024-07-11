//
//  SwitchOnboarding.swift
// Echo
//
//  Created by Gavin Henderson on 31/05/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct SwitchOnboarding: View {
    @Environment(Settings.self) var settings: Settings
    
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
                SwitchControlSection()
            }
            .scrollContentBackground(.hidden)
        }
        
    }
}
