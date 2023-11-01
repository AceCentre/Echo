//
//  OnScreenArrowsOnboarding.swift
//  Echo
//
//  Created by Gavin Henderson on 27/10/2023.
//

import Foundation
import SwiftUI

struct OnScreenArrowsOnboarding: View {
    @EnvironmentObject var access: AccessOptions
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                Image(access.showOnScreenArrows ? "Arrows" : "NoArrows")
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
            Picker(String(localized: "Onscreen Arrows", comment: "Label for onboarding picker"), selection: access.$showOnScreenArrows) {
                Text("Hide", comment: "Label to hide arrows").tag(false)
                Text("Show", comment: "Label to show arrows").tag(true)
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
}
