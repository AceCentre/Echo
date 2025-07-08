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
                print("🔊 DEBUG: Play Sample button tapped")
                playSample()
                print("🔊 DEBUG: Play Sample function called")
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
                print("🔊 DEBUG: Voice button tapped")
                showVoicePicker = true
                print("🔊 DEBUG: showVoicePicker set to true")
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
                            print("🔊 DEBUG: Cancel button tapped")
                            showVoicePicker = false
                        }
                        .padding()
                        Spacer()
                    }

                    VoicePicker(voiceId: $voiceId, voiceName: $voiceName)
                }
                .onAppear {
                    print("🔊 DEBUG: Voice picker sheet being presented")
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
                print("🔊 DEBUG: Test button tapped")
            }
            .padding()

            Spacer()
        }
        .navigationTitle("Voice Picker Debug")
        .onAppear {
            print("🔊 DEBUG: TestVoicePickerView appeared successfully")
            print("🔊 DEBUG: voiceId: '\(voiceId)', voiceName: '\(voiceName)'")
        }
    }
}
