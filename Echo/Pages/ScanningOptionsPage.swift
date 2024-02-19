//
//  ScanningOptionsPage.swift
//  Echo
//
//  Created by Gavin Henderson on 05/10/2023.
//

import Foundation
import SwiftUI

struct ScanningOptionsPage: View {
    @EnvironmentObject var scanningOptions: ScanningOptions
    
    var body: some View {
        Form {
            Section(content: {
                Toggle(
                    String(
                        localized: "Scanning",
                        comment: "Label for toggle to turn scanning off and on"
                    ),
                    isOn: $scanningOptions.scanning
                )
               
                VStack {
                    HStack {
                        Text("Scanning speed", comment: "Slider label to control the speed of scanning")
                        Spacer()
                        Text(String(format: "%.1f", scanningOptions.scanWaitTime) + "s")
                    }
                    Slider(
                        value: $scanningOptions.scanWaitTime,
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
                    isOn: $scanningOptions.scanOnAppLaunch
                )
                Toggle(
                    String(
                        localized: "Scan after selection",
                        comment: "Label for toggle that controls when scanning starts"
                    ),
                    isOn: $scanningOptions.scanAfterSelection
                )
                Stepper(
                    value: $scanningOptions.scanLoops,
                    in: 1...10,
                    step: 1
                ) {
                    Text(
                        "Scan **\(scanningOptions.scanLoops)** times before stopping",
                        comment: "A label that outlines the number of scanning loops the app will go on. Please leave the value in bold."
                    )
                }
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

private struct PreviewWrapper: View {
    @StateObject var scanningOptions = ScanningOptions()

    var body: some View {
        NavigationStack {
            Text("Main Page")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    navigationDestination(isPresented: .constant(true), destination: {
                        ScanningOptionsPage()
                            .environmentObject(scanningOptions)
                            
                    })
                    
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

// periphery:ignore
struct ScanningOptionsPage_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        PreviewWrapper().preferredColorScheme(.light)
    }
}
