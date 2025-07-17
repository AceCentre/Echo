//
//  VoiceOptionsDisplay.swift
// Echo
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation
import SwiftUI

struct VoiceOptionsArea: View {
    var title: String
    var helpText: String

    @Binding var rate: Double
    @Binding var volume: Double
    @Binding var voiceId: String
    @Binding var voiceName: String

    var playSample: () -> Void

    @State private var showVoicePicker = false
    
    var body: some View {
        Section(content: {
            Button(action: {
                // EchoLogger.debug("Play Sample button tapped", category: .voice)
                playSample()
                // EchoLogger.debug("Play Sample function called", category: .voice)
            }, label: {
                Label(
                    String(
                        localized: "Play Sample",
                        comment: "Label for button that plays an audio sample"
                    ),
                    systemImage: "play.circle"
                )
            })
            Button(action: {
                // EchoLogger.debug("Voice button tapped", category: .voice)
                showVoicePicker = true
                //EchoLogger.debug("showVoicePicker set to true", category: .voice)
            }, label: {
                HStack {
                    Text(
                        "Voice",
                        comment: "Label for NavigationLink that takes you to a voice picker page"
                    )
                    Spacer()
                    Text(voiceName)
                        .foregroundStyle(.gray)
                }

            })
            .sheet(isPresented: $showVoicePicker) {
                VStack {
                    HStack {
                        Button("Cancel") {
                            // EchoLogger.debug("Cancel button tapped", category: .voice)
                            showVoicePicker = false
                        }
                        .padding()
                        Spacer()
                    }

                    VoicePicker(voiceId: $voiceId, voiceName: $voiceName)
                }
                .onAppear {
                    EchoLogger.debug("Voice picker sheet being presented", category: .voice)
                }
            }
            
            VStack {
                HStack {
                    Text(
                        "Volume",
                        comment: "Label for a slider that controls the volume of a voice"
                    )
                    Spacer()
                    Text(String(Int(volume)))
                        .foregroundStyle(.gray)
                }
                Slider(
                    value: $volume,
                    in: 0...100,
                    onEditingChanged: { isEditing in
                        if isEditing == false {
                            playSample()
                        }
                    }
                )
            }
            
            VStack {
                HStack {
                    Text(
                        "Rate",
                        comment: "Label for a slider that controls the rate of a voice"
                    )
                    Spacer()
                    Text(String(Int(rate)))
                        .foregroundStyle(.gray)
                }
                Slider(
                    value: $rate,
                    in: 0...100,
                    onEditingChanged: { isEditing in
                        if isEditing == false {
                            playSample()
                        }
                    }
                )
            }
            
        }, header: {
            Text(title)
        }, footer: {
            Text(helpText)
        })
    }
}

struct TestVoicePickerView: View {
    @Binding var voiceId: String
    @Binding var voiceName: String

    var body: some View {
        VStack {
            Text("Voice Picker Test")
                .font(.title)
                .padding()

            Text("Current Voice ID: \(voiceId)")
                .padding()

            Text("Current Voice Name: \(voiceName)")
                .padding()

            Button("Test Button") {
                EchoLogger.debug("Test button tapped", category: .voice)
            }
            .padding()

            Spacer()
        }
        .navigationTitle("Voice Picker Debug")
        .onAppear {
            EchoLogger.debug("TestVoicePickerView appeared successfully", category: .voice)
            EchoLogger.debug("voiceId: '\(voiceId)', voiceName: '\(voiceName)'", category: .voice)
        }
    }
}
