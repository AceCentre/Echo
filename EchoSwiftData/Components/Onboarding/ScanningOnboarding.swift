//
//  ScanningOnboarding.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 30/05/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct ScanningOnboarding: View {
    @Environment(Settings.self) var settings: Settings
    
    var body: some View {
        @Bindable var settingsBindable = settings
        
        VStack {
            VStack {
                ZStack {
                    Image("Scanning")
                        .resizable()
                        .accessibilityLabel(String(
                            localized: "An apple device with letters on screen, represents scanning",
                            comment: "Accesibility label for logo"
                        ))
                        .frame(width: 69, height: 100)
                        .foregroundStyle(Color("aceBlue"))
                    if !settingsBindable.scanning {
                        Image("Slash")
                            .resizable()
                            .frame(width: 89, height: 120)
                            .accessibilityLabel(String(
                                localized: "A slash to indicate disabled",
                                comment: "Accessibility label for slash"
                            ))
                    }
                }
            }.padding(.top)
            VStack {
                BottomText(
                    topText: AttributedString(
                        localized: "Scanning",
                        comment: "Label for the scanning during onboarding"
                    ),
                    bottomText: AttributedString(
                        localized: "Scanning is when Echo automatically cycles through the items in the list one ofter the other reading them aloud one a time.",
                        comment: "Explaination of scanning during onboarding"
                    )
                )
            }.padding()
            Form {
                Section(content: {
                    Toggle(
                        String(
                            localized: "Scanning",
                            comment: "Label for toggle to turn scanning off and on"
                        ),
                        isOn: $settingsBindable.scanning
                    )
                    if settingsBindable.scanning {
                        VStack {
                            HStack {
                                Text("Scanning speed", comment: "Slider label to control the speed of scanning")
                                Spacer()
                                Text(String(format: "%.1f", settingsBindable.scanWaitTime) + "s")
                            }
                            Slider(
                                value: $settingsBindable.scanWaitTime,
                                in: 0.3...10,
                                step: 0.1
                            )
                            Text(
                                "The length of time that Echo will wait before moving onto the next item",
                                comment: "A description of what scanning speed does"
                            )
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Toggle(
                            String(
                                localized: "Scan on app launch",
                                comment: "Label for toggle that controls when scanning starts"
                            ),
                            isOn: $settingsBindable.scanOnAppLaunch
                        )
                        Toggle(
                            String(
                                localized: "Scan after selection",
                                comment: "Label for toggle that controls when scanning starts"
                            ),
                            isOn: $settingsBindable.scanAfterSelection
                        )
                    }
                    
                })
                
            }.scrollContentBackground(.hidden)
        }
    }
}
