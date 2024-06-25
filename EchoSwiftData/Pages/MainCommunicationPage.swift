//
//  MainCommunicationPage.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 07/06/2024.
//

import Foundation
import SwiftUI

struct MainCommunicationPage: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Text("wow")
            }
            .navigationTitle(
                String(
                    localized: "Echo: Auditory Scanning",
                    comment: "The main navigation title for the whole app"
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: {
                        SettingsPage()
                    }, label: {
                        Image(systemName: "slider.horizontal.3").foregroundColor(.blue)
                    })
                    
                }
            }
            .toolbarBackground(.visible, for: .navigationBar, .tabBar)
        }
    }
}
