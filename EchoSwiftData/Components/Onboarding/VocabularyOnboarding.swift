//
//  VocabularyOnboarding.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 24/05/2024.
//

import SwiftUI
import SwiftData

struct VocabularyOnboarding: View {
    @Environment(Settings.self) var settings: Settings
    
    @Query(filter: #Predicate<Vocabulary> { vocab in
        vocab.systemVocab == true
    }) var allVocabs: [Vocabulary]
    
    @State var selectedVocab = Vocabulary(name: "temp")
    
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
                        selection: $selectedVocab
                    ) {
                        ForEach(allVocabs, id: \.self) { vocab in
                            Text(vocab.name).tag(vocab)
                        }
                    }
                })
            }
            .scrollContentBackground(.hidden)
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
}
