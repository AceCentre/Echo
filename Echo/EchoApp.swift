//
// EchoApp.swift
// Echo
//
//  Created by Gavin Henderson on 23/05/2024.
//

import SwiftUI
import SwiftData
import ARKit

@main
struct EchoApp: App {
    @AppStorage("hasLoadedSwitches") var hasLoadedSwitches = false
    @AppStorage("hasLoadedFacialGestureSwitches") var hasLoadedFacialGestureSwitches = false
    @StateObject var errorHandling = ErrorHandling()
    @StateObject var controllerManager = ControllerManager()
    
    var body: some Scene {
        WindowGroup {
            SwiftDataInitialiser(errorHandling: errorHandling)
            ErrorView(errorHandling: errorHandling)
        }
        .environmentObject(controllerManager)
        .environmentObject(errorHandling)
        .modelContainer(for: [Settings.self, Switch.self, FacialGestureSwitch.self]) { result in
            do {
                let container = try result.get()
                
                /**
                Delete existing back nodes as we no longer want to have them in the database
                 */
                let nodes = try container.mainContext.fetch(FetchDescriptor<Node>())
                let nodesToDelete = nodes.filter { currentNode in
                    return currentNode.type == .back
                }
                for currentNode in nodesToDelete {
                    container.mainContext.delete(currentNode)
                }
                try container.mainContext.save()
                
                /*+
                 Create the initial settings object if it does not exist
                 */
                let allSettings = try container.mainContext.fetch(FetchDescriptor<Settings>())
                var currentSettings = Settings()
                if let firstSettings = allSettings.first {
                    currentSettings = firstSettings
                } else {
                    container.mainContext.insert(currentSettings)
                }
                try container.mainContext.save()
                
                if let url = container.configurations.first?.url.path(percentEncoded: false) {
                    print("Database Location: \"\(url)\"")
                }
                
                /*
                 Initialise the default switches once
                 */
                if !hasLoadedSwitches {
                    container.mainContext.insert(
                        Switch(
                            name: String(localized: "Switch 1 (Enter)", comment: "Default switch name"),
                            key: .keyboardReturnOrEnter,
                            tapAction: .nextNode,
                            holdAction: .none
                        )
                    )
                    container.mainContext.insert(
                        Switch(
                            name: String(localized: "Switch 2 (Space)", comment: "Default switch name"),
                            key: .keyboardSpacebar,
                            tapAction: .select,
                            holdAction: .none
                        )
                    )
                    try container.mainContext.save()
                    hasLoadedSwitches = true
                }

                /*
                 Initialise the default facial gesture switches once
                 */
                // Don't create any default facial gesture switches
                // Users can add them manually if they want to use facial gestures
                // This prevents unwanted switches from appearing by default

                // Always set the flag to true after checking
                if !hasLoadedFacialGestureSwitches {
                    hasLoadedFacialGestureSwitches = true
                }

                /*
                 Insert the system vocabularies
                 */
                let existingVocabs = try container.mainContext.fetch(FetchDescriptor<Vocabulary>())
                for newSystemVocab in Vocabulary.getSystemVocabs() {
                    if !existingVocabs.contains(where: { $0.slug == newSystemVocab.slug }) {
                        container.mainContext.insert(newSystemVocab)
                    }
                }
                
                
                try container.mainContext.save()
                
                
                /*
                 Set the default vocab if there is no vocab
                 */
                if currentSettings.currentVocab == nil {
                    let defaultVocab = try container.mainContext.fetch(FetchDescriptor<Vocabulary>(
                        predicate: #Predicate {
                            $0.isDefault == true
                        }
                    ))
                    
                    if let unwrappedVocab = defaultVocab.first {
                        currentSettings.currentVocab = unwrappedVocab
                        try container.mainContext.save()
                    }
                }
                
                /*
                 Create and store voices using actual available system voices
                 */
                if currentSettings.cueVoice == nil || currentSettings.speakingVoice == nil {
                    let availableVoices = AVSpeechSynthesisVoice.speechVoices()

                    // Get voices for current locale first, then fallback to English, then any voice
                    let currentLocale = Locale.current.identifier
                    let localeVoices = availableVoices.filter { $0.language == currentLocale }
                    let languageCode = String(currentLocale.prefix(2))
                    let languageVoices = localeVoices.isEmpty ? availableVoices.filter { $0.language.hasPrefix(languageCode) } : localeVoices
                    let usableVoices = languageVoices.isEmpty ? availableVoices : languageVoices

                    // Create cue voice (use first available voice)
                    if currentSettings.cueVoice == nil {
                        let cueVoice: Voice
                        if let firstVoice = usableVoices.first {
                            cueVoice = Voice(rate: 35, volume: 100, voiceId: firstVoice.identifier, voiceName: firstVoice.name)
                            EchoLogger.debug("Created cue voice: \(firstVoice.name) (\(firstVoice.identifier))", category: .voice)
                        } else {
                            // Ultimate fallback - let the system choose
                            cueVoice = Voice(rate: 35, volume: 100, voiceId: "", voiceName: "System Default")
                            EchoLogger.debug("Created cue voice: System Default", category: .voice)
                        }

                        container.mainContext.insert(cueVoice)
                        try container.mainContext.save()
                        currentSettings.cueVoice = cueVoice
                        try container.mainContext.save()
                    }

                    // Create speaking voice (use second available voice if possible, otherwise first)
                    if currentSettings.speakingVoice == nil {
                        let speakingVoice: Voice
                        if usableVoices.count > 1 {
                            let secondVoice = usableVoices[1]
                            speakingVoice = Voice(rate: 35, volume: 100, voiceId: secondVoice.identifier, voiceName: secondVoice.name)
                            EchoLogger.debug("Created speaking voice: \(secondVoice.name) (\(secondVoice.identifier))", category: .voice)
                        } else if let firstVoice = usableVoices.first {
                            speakingVoice = Voice(rate: 35, volume: 100, voiceId: firstVoice.identifier, voiceName: firstVoice.name)
                            EchoLogger.debug("Created speaking voice: \(firstVoice.name) (\(firstVoice.identifier))", category: .voice)
                        } else {
                            // Ultimate fallback - let the system choose
                            speakingVoice = Voice(rate: 35, volume: 100, voiceId: "", voiceName: "System Default")
                            EchoLogger.debug("Created speaking voice: System Default", category: .voice)
                        }

                        container.mainContext.insert(speakingVoice)
                        try container.mainContext.save()
                        currentSettings.speakingVoice = speakingVoice
                        try container.mainContext.save()
                    }
                }
            } catch {
                errorHandling.handle(error: error)
            }
        }
    }
}

struct SwiftDataInitialiser: View {
    @ObservedObject var errorHandling: ErrorHandling
    
    
    @Environment(\.modelContext) var context
    @Environment(\.scenePhase) var scenePhase

    @Query var settings: [Settings]
    
    var body: some View {
        ContentView(errorHandling: errorHandling)
            .environment(settings.first ?? Settings())           
            .onChange(of: scenePhase) {
                /*
                 When the app goes into the background we want to clean up our data
                 We find nodes that have no parent and are left out of a tree (not root nodes though)
                 */
                if scenePhase == .background  {
                    do {
                        let nodes = try context.fetch(FetchDescriptor<Node>())
                        
                        let nodesToDelete = nodes.filter { currentNode in
                            if currentNode.type == .root || currentNode.type == .rootAndSpelling {
                                return false
                            }
                            
                            return currentNode.parent == nil
                        }
                                                
                        for currentNode in nodesToDelete {
                            context.delete(currentNode)
                        }
                    } catch {
                        errorHandling.handle(error: EchoError.cleanupFailed)
                    }
                }
            }
    }
}
