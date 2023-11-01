//
//  Intro.swift
//  Echo
//
//  Created by Gavin Henderson on 27/10/2023.
//

import Foundation
import SwiftUI

struct IntroStep: View {
    var body: some View {
        VStack {
            VideoPlayerOnboarding()
            BottomText(
                topText: AttributedString(
                    localized: "Welcome to **Echo**",
                    comment: "Welcome message in onboarding"
                ),
                bottomText: AttributedString(
                    localized: "Communication for the visual impaired",
                    comment: "Explain what Echo is"
                )
            )
        }
    }
}
