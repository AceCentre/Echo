//
//  VocabularyOnboarding.swift
//  Echo
//
//  Created by Gavin Henderson on 19/02/2024.
//

import SwiftUI

struct VocabularyOnboarding: View {
    @EnvironmentObject var itemsList: ItemsList
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                ZStack {
                    Image(systemName: "list.bullet.indent")
                        .resizable()
                        .frame(width: 200, height: 144)
                        .foregroundStyle(Color("aceBlue"))
                }
                Spacer()
            }
            VStack {
                BottomText(
                    topText: AttributedString(
                        localized: "**Vocabulary**",
                        comment: "Label for the Vocabulary during onboarding"
                    ),
                    bottomText: AttributedString(
                        localized: "Predict which words and letters come next and you enter each letter.",
                        comment: "Select the vocabulary of phrases, words and letters to be used"
                    )
                )
            }.padding()
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
                })
            }
            .scrollContentBackground(.hidden)

        }

    }
}
