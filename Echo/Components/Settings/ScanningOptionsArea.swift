//
//  ScanningOptionsArea.swift
// Echo
//
//  Created by Gavin Henderson on 27/06/2024.
//

import Foundation
import SwiftUI

struct ScanningOptionsArea: View {
    @Environment(Settings.self) var settings: Settings
    
    var body: some View {
        @Bindable var settingsBindable = settings

        Form {

            Section(content: {
                Toggle(
                    String(
                        localized: "Scanning",
                        comment: "Label for toggle to turn scanning off and on"
                    ),
                    isOn: $settingsBindable.scanning
                )
               
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
                Stepper(
                    value: $settingsBindable.scanLoops,
                    in: 1...10,
                    step: 1
                ) {
                    Text(
                        "Scan **\(settingsBindable.scanLoops)** times before stopping",
                        comment: "A label that outlines the number of scanning loops the app will go on. Please leave the value in bold."
                    )
                }
                Toggle(
                    String(
                        localized: "Make first loop fast",
                        comment: "Label for toggle that controls when the first is faster"
                    ),
                    isOn: $settingsBindable.fastFirstLoop
                )
            }, header: {}, footer: {
                Text(
                    "Scanning is when Echo automatically cycles through the items in the list one ofter the other reading them aloud one a time.",
                    comment: "The footer explaining what scanning loops is"
                )
            })
            .navigationTitle(
                String(
                    localized: "Scanning Options",
                    comment: "The navigation title for the scanning options page"
                )
            )
        }
    }
}
