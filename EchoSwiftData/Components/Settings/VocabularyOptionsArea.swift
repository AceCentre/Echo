//
//  VocabularyOptionsArea.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 27/06/2024.
//
import SwiftUI
import SwiftData

struct VocabularyOptionsArea: View {
    @Environment(Settings.self) var settings: Settings

    @Query(sort: \Vocabulary.createdAt) var allVocabs: [Vocabulary]
    
    @State var selectedVocab = Vocabulary(name: "temp", rootNode: Node(type: .root))
    
    var body: some View {
        @Bindable var bindableSettings = settings

        Form {
            Section(content: {
                Picker(
                    String(
                        localized: "Vocabulary",
                        comment: "The label that is shown next to the vocab picker"
                    ),
                    selection: $selectedVocab
                ) {
                    ForEach(allVocabs, id: \.self) { vocab in
                        Text(vocab.name).tag(vocab)
                    }
                }
            }, header: {
                Text("Vocabulary", comment: "Header of vocabulary options")
            }, footer: {
                Text("Select the vocabulary of phrases, words and letters to be used", comment: "Footer of vocabulary options")
            })
            Section(content: {
                Stepper(
                    value: $bindableSettings.vocabHistory,
                    in: 1...10,
                    step: 1
                ) {
                    Text(
                        "Show **\(bindableSettings.vocabHistory)** level of your vocabulary",
                        comment: "Describe to the user the number of history levels"
                    )
                }
            }, header: {
                Text("History", comment: "Header for settings about history")
            }, footer: {
                Text("This is the number of levels of your phrases to show at once.", comment: "Footer for settings about history")
            })
        }
        .navigationTitle(
            String(
                localized: "Vocabulary",
                comment: "The navigation title for the Vocabulary options page"
            )
        )
        .onAppear {
            if let unwrapped = settings.currentVocab {
                selectedVocab = unwrapped
            }
        }
        .onChange(of: selectedVocab) {
            settings.currentVocab = selectedVocab
        }
    }
}
