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
    var body: some Scene {
        WindowGroup {
            SwiftDataInitialiser()
        }.modelContainer(for: Settings.self) { result in
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
