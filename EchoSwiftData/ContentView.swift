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
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                Button(action: {
                    settings.showOnboarding = true
                }, label: {
                    Text("reset")
                })
            }
            .padding()
        }
        
    }
}

#Preview {
    ContentView()
}
