//
//  VoicePicker.swift
// Echo
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation
import SwiftUI
import AVFAudio

struct VoicePicker: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var voiceList = AvailableVoices()
    
    @Binding var voiceId: String
    // periphery:ignore
    @Binding var voiceName: String
    
    var body: some View {
        Form {
            ForEach(voiceList.sortedKeys(), id: \.self) { lang in
                Section(content: {
                    let voices = voiceList.voicesForLang(lang)
                    ForEach(Array(voices.enumerated()), id: \.element) { _, voice in
                        Button(action: {
                            voiceId = voice.identifier
                            voiceName = "\(voice.name) (\(getLanguage(voice.language)))"
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            HStack {
                                Text(voice.name)
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                if voiceId == voice.identifier {
                                    Image(systemName: "checkmark")
                                }
                            }
                        })
                    }
                },
                header: {
                    Text(getLanguageAndRegion(lang))
                })
            }
            
        }
    }
}
