//
//  EchoApp.swift
//  Echo
//
//  Created by Gavin Henderson on 14/07/2023.
//

import SwiftUI
import SharedEcho

@main
struct EchoApp: App {
    @StateObject var voiceEngine: VoiceEngine = VoiceEngine()
    @StateObject var itemsList: ItemsList = ItemsList()
    @StateObject var accessOptions: AccessOptions = AccessOptions()
    @StateObject var scanningOptions: ScanningOptions = ScanningOptions()
    @StateObject var spellingOptions: SpellingOptions = SpellingOptions()
    @StateObject var analytics: Analytics = Analytics()
    @StateObject var rating: Rating = Rating()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(voiceEngine)
                .environmentObject(itemsList)
                .environmentObject(accessOptions)
                .environmentObject(scanningOptions)
                .environmentObject(spellingOptions)
                .environmentObject(analytics)
                .environmentObject(rating)
                .onAppear {
                    #if DEBUG
                    for current in StorageKeys.allowedViaTest {
                        if let unwrappedValue = ProcessInfo.processInfo.environment[current] {
                            UserDefaults.standard.setValue(unwrappedValue == "true", forKey: current)
                        }
                    }
                    #endif
                    
                    rating.countOpen()
 
                    itemsList.loadAnalytics(analytics)
                    spellingOptions.loadAnalytics(analytics: analytics)
                    voiceEngine.load(analytics: analytics)
                    accessOptions.load()
                    itemsList.loadSpelling(spellingOptions)
                    itemsList.loadEngine(voiceEngine)
                    itemsList.loadScanning(scanningOptions)
                    
                    analytics.load(
                        voiceEngine: voiceEngine, accessOptions: accessOptions, scanningOptions: scanningOptions, spellingOptions: spellingOptions
                    )
                    analytics.event(.appLaunch)
                }
                .onDisappear {
                    voiceEngine.save()
                    accessOptions.save()
                }
        }
        
    }
}
