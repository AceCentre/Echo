//
//  Analytics.swift
//  Echo
//
//  Created by Gavin Henderson on 30/10/2023.
//

import Foundation
import SwiftUI

struct AnalyticsOnboarding: View {
    @EnvironmentObject var analytics: Analytics
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                ZStack {
                    Image(systemName: "chart.xyaxis.line")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .foregroundStyle(Color("aceBlue"))
                    if !analytics.allowAnalytics {
                        Image("Slash")
                            .resizable()
                            .rotationEffect(.degrees(90))
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
                    localized: "Collect Analytics?",
                    comment: "Header for analytics onboarding page"
                ),
                bottomText: AttributedString(
                    localized: "We collect analytics to help us improve the app. All data is anonymised and never shared with any third party.",
                    comment: "Explaination of analytics controls"
                )
            )
            Picker(String(localized: "Analytics", comment: "Label for analytics picker"), selection: analytics.$allowAnalytics) {
                Text("Do not track", comment: "Label to disable swipe").tag(false)
                Text("Allow tracking", comment: "Label to enable swipe").tag(true)
            }
            .pickerStyle(.segmented)
        }
        .padding(.horizontal)
    }
}
