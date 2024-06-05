//
//  EchoSwiftDataApp.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 23/05/2024.
//

import SwiftUI
import SwiftData

@main
struct EchoSwiftDataApp: App {
    @AppStorage("hasLoadedSwitches") var hasLoadedSwitches = false
    
    var body: some Scene {
        WindowGroup {
            SwiftDataInitialiser()
        }
        .modelContainer(for: [Settings.self, Switch.self]) { result in
            do {
                /*
                 Create the initial settings object if it does not exist
                 */
                let container = try result.get()
                let allSettings = try container.mainContext.fetch(FetchDescriptor<Settings>())
                var currentSettings = Settings()
                if let firstSettings = allSettings.first {
                    currentSettings = firstSettings
                } else {
                    container.mainContext.insert(currentSettings)
                }
                try container.mainContext.save()
                
                /*
                 Initialise the default switches once
                 */
                if !hasLoadedSwitches {
                    container.mainContext.insert(
                        Switch(
                            name: "Enter Switch",
                            key: .keyboardReturnOrEnter,
                            tapAction: .nextNode,
                            holdAction: .none
                        )
                    )
                    container.mainContext.insert(
                        Switch(
                            name: "Space Switch",
                            key: .keyboardSpacebar,
                            tapAction: .select,
                            holdAction: .none
                        )
                    )
                    try container.mainContext.save()
                    hasLoadedSwitches = true
                }

                
                /*
                 Insert the system vocabularies, this performs an upsert so won't create any duplicates
                 */
                for newSystemVocab in Vocabulary.getSystemVocabs() {
                    container.mainContext.insert(newSystemVocab)
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
                 Create and store a cueVoice
                 */
                if currentSettings.cueVoice == nil {
                    let cueVoice = Voice(
                        rate: 35,
                        volume: 100,
                        voiceId: "unknown",
                        voiceName: "unkown"
                    )
                    cueVoice.setToDefaultCueVoice()
                    
                    container.mainContext.insert(cueVoice)
                    try container.mainContext.save()
                    
                    currentSettings.cueVoice = cueVoice
                    try container.mainContext.save()
                }
                
                /*
                 Create and store a speakingVoice
                 */
                if currentSettings.speakingVoice == nil {
                    let speakingVoice = Voice(
                        rate: 35,
                        volume: 100,
                        voiceId: "unknown",
                        voiceName: "unkown"
                    )
                    speakingVoice.setToDefaultSpeakingVoice()
                    
                    container.mainContext.insert(speakingVoice)
                    try container.mainContext.save()
                    
                    currentSettings.speakingVoice = speakingVoice
                    try container.mainContext.save()
                }
            } catch {
                /// TODO: Properly address error
                print(error)
            }
        }
    }
}

struct SwiftDataInitialiser: View {
    @Environment(\.modelContext) var context
    @Query var settings: [Settings]
    
    var body: some View {
        ContentView()
            .environment(settings.first ?? Settings())
    }
}
