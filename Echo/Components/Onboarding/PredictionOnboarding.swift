//
//  PredictionOnboarding.swift
// Echo
//
//  Created by Gavin Henderson on 30/05/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct PredictionOnboarding: View {
    @Environment(Settings.self) var settings: Settings

    @State var prediction: Bool = true
    @State var allWordPrediction: Bool = true
    @State var showIndividualPredictionOptions: Bool = false
    
    func initState() {
        if settings.wordPrediction == settings.letterPrediction {
            prediction = settings.wordPrediction
        } else {
            showIndividualPredictionOptions = true
        }
        
        allWordPrediction = settings.wordPrediction
        settings.appleWordPrediction = settings.wordPrediction
    }
    
    var body: some View {
        @Bindable var settingsBindable = settings

        VStack {
            VStack {
                Spacer()
                ZStack {
                    Image(systemName: "keyboard")
                        .resizable()
                        .frame(width: 200, height: 144)
                        .foregroundStyle(Color("aceBlue"))
                    if !prediction || (!settings.wordPrediction && !settings.appleWordPrediction && !settings.letterPrediction) {
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
                    @Bindable var settingsBindable = settings
                    if showIndividualPredictionOptions {
                        Toggle(
                            String(
                                localized: "Letter prediction",
                                comment: "Label for toggle to turn letter based prediction off and on"
                            ),
                            isOn: $settingsBindable.letterPrediction
                        )
                        Toggle(
                            String(
                                localized: "Word prediction",
                                comment: "Label for toggle to turn word prediction off and on"
                            ),
                            isOn: $allWordPrediction
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
                        selection: $settingsBindable.predictionLanguage
                    ) {
                        ForEach(PredictionLanguage.allCases) { language in
                            Text(language.display).tag(language)
                        }
                    }
                })
            }
            .scrollContentBackground(.hidden)
            .onAppear {
                initState()
            }
            .onChange(of: prediction) {
                settings.wordPrediction = prediction
                settings.appleWordPrediction = prediction
                settings.letterPrediction = prediction
            }
            .onChange(of: allWordPrediction) {
                settings.wordPrediction = allWordPrediction
                settings.appleWordPrediction = allWordPrediction
            }
        }
    }
}
