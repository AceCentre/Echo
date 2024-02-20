//
//  VocabularyPage.swift
//  Echo
//
//  Created by Gavin Henderson on 19/02/2024.
//

import SwiftUI

struct VocabularyPage: View {
    @EnvironmentObject var itemsList: ItemsList
    
    var body: some View {
        Form {
            Section(content: {
                Picker(
                    String(
                        localized: "Vocabulary",
                        comment: "The label that is shown next to the vocab picker"
                    ),
                    selection: itemsList.$vocabulary
                ) {
                    ForEach(Vocabulary.allCases) { vocab in
                        Text(vocab.tree.name).tag(vocab)
                    }
                }
            }, header: {
                Text("Vocabulary")
            }, footer: {
                Text("Select the vocabulary of phrases, words and letters to be used")
            })
            Section(content: {
                Stepper(
                    value: $itemsList.history,
                    in: 1...10,
                    step: 1
                ) {
                    Text(
                        "Show **\(itemsList.history)** level of your vocabulary"
                    )
                }
            }, header: {
                Text("History")
            }, footer: {
                Text("This is the number of levels of your phrases to show at once.")
            })
        }
        .navigationTitle(
            String(
                localized: "Vocabulary",
                comment: "The navigation title for the Vocabulary options page"
            )
        )
    }
}
