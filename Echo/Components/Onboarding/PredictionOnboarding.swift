//
//  PredictionOnboarding.swift
//  Echo
//
//  Created by Gavin Henderson on 30/10/2023.
//

import Foundation
import SwiftUI

struct PredictionOnboarding: View {
    @EnvironmentObject var spellingOptions: SpellingOptions
    
    @State var prediction: Bool = true
    @State var showIndividualPredictionOptions: Bool = false
    
    func initState() {
        if spellingOptions.wordPrediction == spellingOptions.letterPrediction {
            prediction = spellingOptions.wordPrediction
        } else {
            showIndividualPredictionOptions = true
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                ZStack {
                    Image(systemName: "keyboard")
                        .resizable()
                        .frame(width: 200, height: 144)
                        .foregroundStyle(Color("aceBlue"))
                    if !prediction || (!spellingOptions.allWordPrediction && !spellingOptions.letterPrediction) {
                        Image("Slash")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .accessibilityLabel(String(
                                localized: "A slash to indicate disabled",
                                comment: "Accessibility label for slash"
                            ))
                    }
                }
                Spacer()
            }
            VStack {
                BottomText(
                    topText: AttributedString(
                        localized: "**Word and Letter Prediction**",
                        comment: "Label for the prediction during onboarding"
                    ),
                    bottomText: AttributedString(
                        localized: "Predict which words and letters come next and you enter each letter.",
                        comment: "Explaination of prediction during onboarding"
                    )
                )
            }.padding()
            Form {
                Section(content: {
                    if showIndividualPredictionOptions {
                        Toggle(
                            String(
                                localized: "Letter prediction",
                                comment: "Label for toggle to turn letter based prediction off and on"
                            ),
                            isOn: spellingOptions.$letterPrediction
                        )
                        Toggle(
                            String(
                                localized: "Word prediction",
                                comment: "Label for toggle to turn word prediction off and on"
                            ),
                            isOn: $spellingOptions.allWordPrediction
                        )
                    } else {
                        Toggle(
                            String(
                                localized: "Prediction",
                                comment: "Label for toggle to turn prediction off and on"
                            ),
                            isOn: $prediction
                        )
                    }
                    Picker(
                        String(
                            localized: "Predition Language",
                            comment: "The label that is shown next to the language picker"
                        ),
                        selection: spellingOptions.$predictionLanguage
                    ) {
                        ForEach(PredictionLanguage.allLanguages) { language in
                            Text(language.display).tag(language.id)
                        }
                    }
                })
            }
            .scrollContentBackground(.hidden)
            .onAppear {
                initState()
            }
            .onChange(of: prediction) {
                spellingOptions.allWordPrediction = prediction
                spellingOptions.letterPrediction = prediction
            }
        }
    }
}
