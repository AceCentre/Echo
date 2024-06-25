//
//  ContentView.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 23/05/2024.
//

import SwiftUI

struct ContentView: View {
    @Environment(Settings.self) var settings
    
    var body: some View {
        if settings.showOnboarding {
            Onboarding(endOnboarding: {
                settings.showOnboarding = false
            })
        } else {
            MainCommunicationPage()
        }
        
    }
}

#Preview {
    ContentView()
}
