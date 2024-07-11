//
//  SecondStep.swift
// Echo
//
//  Created by Gavin Henderson on 24/05/2024.
//

import Foundation
import SwiftUI

struct SecondStep: View {
    var body: some View {
        VStack {
            VStack {
                Spacer()
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .foregroundStyle(Color("aceBlue"))

                Spacer()
            }
            BottomText(
                topText: AttributedString(
                    localized: "Getting Started",
                    comment: "Getting started onboarding"
                ),
                bottomText: AttributedString(
                    localized: "Lets setup **Echo**. You can change your settings at any time.",
                    comment: "Explain of Echo onboarding process"
                )
            )
        }
        .padding(.horizontal)
    }
}
