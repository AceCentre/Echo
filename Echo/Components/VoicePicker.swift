//
//  VoicePicker.swift
//  Echo
//
//  Created by Gavin Henderson on 29/09/2023.
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

private struct PreviewWrapper: View {
    @State var voiceId = ""
    @State var voiceName = ""
    
    var body: some View {
        NavigationStack {
            Text("Main Page")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        navigationDestination(isPresented: .constant(true), destination: {
                            VoicePicker(
                                voiceId: $voiceId,
                                voiceName: $voiceName
                            )
                        })
                        
                    }
                }
                .navigationTitle("Voice Options")
                .navigationBarTitleDisplayMode(.inline)
            
        }
        
    }
}

// periphery:ignore
struct VoicePickerPage_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        PreviewWrapper().preferredColorScheme(.light)
        PreviewWrapper().preferredColorScheme(.dark)
        
    }
}
