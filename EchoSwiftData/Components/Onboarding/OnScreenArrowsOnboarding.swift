//
//  OnScreenArrowsOnboarding.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 31/05/2024.
//

import Foundation
import SwiftUI

struct OnScreenArrowsOnboarding: View {
    @Environment(Settings.self) var settings: Settings
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                Image(settings.showOnScreenArrows ? "Arrows" : "NoArrows")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .accessibilityLabel(String(localized: "A four way arrow keypad", comment: "Accessibility label for arrows"))
                Spacer()
            }
           
            BottomText(
                topText: AttributedString(
                    localized: "On Screen Arrows?",
                    comment: "Getting started onboarding"
                ),
                bottomText: AttributedString(
                    localized: "Control **Echo** using an arrow keypad on screen.",
                    comment: "Explain of Echo onboarding process"
                )
            )
            @Bindable var settingsBindable = settings
            Picker(String(localized: "Onscreen Arrows", comment: "Label for onboarding picker"), selection: $settingsBindable.showOnScreenArrows) {
                Text("Hide", comment: "Label to hide arrows").tag(false)
                Text("Show", comment: "Label to show arrows").tag(true)
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
}
