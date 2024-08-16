//
//  SpellingOptionsArea.swift
// Echo
//
//  Created by Gavin Henderson on 27/06/2024.
//

import Foundation
import SwiftUI

struct SpellingOptionsArea: View {
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
        
        Form {
            
            Section(content: {
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
                if allWordPrediction {
                    Stepper(
                        value: $settingsBindable.wordPredictionLimit,
                        in: 1...10,
                        step: 1
                    ) {
                        HStack {
                            Text(
                                "Word prediction limit",
                                comment: "Label for the stepper that controls word prediction limit"
                            )
                            Spacer()
                            Text(String(settingsBindable.wordPredictionLimit))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }, header: {
                Text(
                    "Prediction",
                    comment: "Label for the section in settings about prediction"
                )
            }, footer: {
                Text(
                    "Prediction helps you to get to the words you want to speak faster",
                    comment: "Footer for the section in settings about prediction"
                )
            })
            
            Section(content: {
                Picker(
                    String(
                        localized: "Language",
                        comment: "The label that is shown next to the language picker"
                    ),
                    selection: $settingsBindable.predictionLanguage
                ) {
                    ForEach(PredictionLanguage.allCases) { language in
                        Text(language.display).tag(language)
                    }
                }
                Picker(
                    String(
                        localized: "Alphabet Order",
                        comment: "The label that is shown next to the alphabet order picker"
                    ),
                    selection: $settingsBindable.characterOrderId
                ) {
                    ForEach(CharacterOrder.allCases) { order in
                        Text(order.display).tag(order.id)
                    }
                }
            }, header: {
                Text("Language and Alphabet", comment: "Header for the language settings")
            }, footer: {
                Text(
                    "The language chosen here will change the alphabet that is shown and will change which words are used for prediction",
                    comment: "Footer for the language settings"
                )
            })
            
            Section(content: {
                Picker(String(localized: "Display control commands", comment: "Picker label for control commands"), selection: $settingsBindable.controlCommandPosition) {
                    Text("Hide", comment: "Picker option for control command").tag(ControlCommandDisplayOptions.hide)
                    Text("End of list", comment: "Picker option for control command").tag(ControlCommandDisplayOptions.bottom)
                    Text("Start of list", comment: "Picker option for control command").tag(ControlCommandDisplayOptions.top)
                }
            }, header: {
                Text(
                    "Control Commands",
                    comment: "Header for commands area"
                )
            }, footer: {
                Text(
                    "The control commands are commands like backspace and clear. They can be shown the list of items and selected.",
                    comment: "Footer for commands area"
                )
            })
            
            Section(content: {
                Toggle(
                    String(
                        localized: "Use Prompts",
                        comment: "Label for toggle prompts"
                    ),
                    isOn: $settingsBindable.wordAndLetterPrompt
                )
            }, header: {
                Text(
                    "Word and Letter Prompt",
                    comment: "Label for the section in settings about prompts"
                )
            }, footer: {
                Text(
                    "Echo prefixes some items with 'current sentence' and 'current word'. However, this might slow you down so you may choose to disable the prompt.",
                    comment: "Footer for the section in settings about prompts"
                )
            })
            
        }
        .navigationTitle(
            String(
                localized: "Spelling & Alphabet Options",
                comment: "The navigation title for the Spelling & Alphabet options page"
            )
        )
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
