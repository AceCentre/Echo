//
//  Swipe.swift
// Echo
//
//  Created by Gavin Henderson on 31/05/2024.
//

import Foundation
import SwiftUI

struct SwipeOnboarding: View {
    @Environment(Settings.self) var settings: Settings
    
    var body: some View {
        VStack {
            
            VStack {
                Spacer()
                ZStack {
                    Image(systemName: "hand.draw")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(Color("aceBlue"))
                    if !settings.allowSwipeGestures {
                        Image("Slash")
                            .resizable()
                            .frame(width: 200, height: 200)
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
                    localized: "Swipe?",
                    comment: "Header for swipe onboarding page"
                ),
                bottomText: AttributedString(
                    localized: "Control **Echo** using Swipes",
                    comment: "Explaination of swipe controls"
                )
            )
            @Bindable var settingsBindable = settings
            Picker(String(localized: "Swipe Gestures", comment: "Label for swipe picker"), selection: $settingsBindable.allowSwipeGestures) {
                Text("Disable", comment: "Label to disable swipe").tag(false)
                Text("Enable", comment: "Label to enable swipe").tag(true)
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
}
