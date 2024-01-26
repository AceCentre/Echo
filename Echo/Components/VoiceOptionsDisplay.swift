//
//  VoiceOptions.swift
//  Echo
//
//  Created by Gavin Henderson on 04/10/2023.
//

import Foundation
import SwiftUI

struct VoiceOptionsArea: View {
    var title: String
    var helpText: String
    
    @Binding var pitch: Double
    @Binding var rate: Double
    @Binding var volume: Double
    @Binding var voiceId: String
    @Binding var voiceName: String
    
    var playSample: () -> Void
    
    var body: some View {
        Section(content: {
            Button(action: {
                playSample()
            }, label: {
                Label(
                    String(
                        localized: "Play Sample",
                        comment: "Label for button that plays an audio sample"
                    ),
                    systemImage: "play.circle"
                )
            })
            NavigationLink(destination: {
                VoicePicker(
                    voiceId: $voiceId,
                    voiceName: $voiceName
                )
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
            VStack {
                HStack {
                    Text(
                        "Pitch",
                        comment: "Label for a slider that controls the pitch of a voice"
                    )
                    Spacer()
                    Text(String(Int(pitch)))
                        .foregroundStyle(.gray)
                }
                Slider(
                    value: $pitch,
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
