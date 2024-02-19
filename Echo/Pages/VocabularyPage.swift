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
        }
        .navigationTitle(
            String(
                localized: "Vocabulary",
                comment: "The navigation title for the Vocabulary options page"
            )
        )
    }
}
