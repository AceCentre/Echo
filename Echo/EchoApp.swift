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
    @StateObject var voiceEngine: VoiceController = VoiceController()
    @StateObject var itemsList: ItemsList = ItemsList()
    @StateObject var accessOptions: AccessOptions = AccessOptions()
    @StateObject var scanningOptions: ScanningOptions = ScanningOptions()
    @StateObject var spellingOptions: SpellingOptions = SpellingOptions()
    @StateObject var analytics: Analytics = Analytics()
    @StateObject var rating: Rating = Rating()
    @StateObject var controllerManager = ControllerManager()
    @StateObject var errorHandling = ErrorHandling()

    @State var loading = true
    
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage(StorageKeys.showOnboarding) var showOnboarding = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if loading {
                    VStack {
                        ProgressView()
                        Text("Echo is loading, thank you for waiting", comment: "Text shown on loading screen.")
                    }
                } else {
                    ContentView(showOnboarding: $showOnboarding)
                }
                ErrorView(errorHandling: errorHandling)
            }
                .environmentObject(errorHandling)
                .environmentObject(voiceEngine)
                .environmentObject(itemsList)
                .environmentObject(accessOptions)
                .environmentObject(scanningOptions)
                .environmentObject(spellingOptions)
                .environmentObject(analytics)
                .environmentObject(rating)
                .environmentObject(controllerManager)
                .onAppear {
                    loading = true
                    voiceEngine.setPhase(scenePhase)
                    #if DEBUG
                    for current in StorageKeys.allowedViaTest {
                        if let unwrappedValue = ProcessInfo.processInfo.environment[current] {
                            UserDefaults.standard.setValue(unwrappedValue == "true", forKey: current)
                        }
                    }
                    #endif
                    
                    rating.countOpen()
 
                    voiceEngine.load(analytics: analytics)
                    accessOptions.load()
                    
                    itemsList.loadEngine(voiceEngine)
                    itemsList.loadSpelling(spellingOptions)
                    itemsList.loadScanning(scanningOptions)
                    itemsList.loadErrorHandling(errorHandling)
                    
                    controllerManager.loadItems(itemsList)
                    controllerManager.loadAnalytics(analytics)
                    
                    analytics.load(
                        voiceEngine: voiceEngine, accessOptions: accessOptions, scanningOptions: scanningOptions, spellingOptions: spellingOptions
                    )
                    analytics.event(.appLaunch)
                                        
                    loading = false
                }
                .onDisappear {
                    voiceEngine.save()
                    accessOptions.save()
                }
                .onChange(of: scenePhase) {
                    voiceEngine.setPhase(scenePhase)
                    if scenePhase == .active && showOnboarding == false {
                        itemsList.onAppear()
                    }
                }
        }
        
    }
}
