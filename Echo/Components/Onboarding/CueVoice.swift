//
//  CueVoice.swift
//  Echo
//
//  Created by Gavin Henderson on 27/10/2023.
//

import Foundation
import SwiftUI
import AVFAudio

struct CueVoiceOnboarding: View {
    @EnvironmentObject var voiceEngine: VoiceEngine
    
    @State var cuePitch: Double = 0
    @State var cueVolume: Double = 0
    @State var cueRate: Double = 0
    @State var cueVoiceId: String = ""
    @State var cueVoiceName: String = ""
    
    func loadSettings() {
        cuePitch = Double(voiceEngine.cueVoiceOptions.pitch)
        cueVolume = Double(voiceEngine.cueVoiceOptions.volume)
        cueRate = Double(voiceEngine.cueVoiceOptions.rate)
    }
    
    func loadVoices() {
        cueVoiceId = voiceEngine.cueVoiceOptions.voiceId
        
        let cueVoice = AVSpeechSynthesisVoice(identifier: cueVoiceId) ?? AVSpeechSynthesisVoice()
        
        cueVoiceName = "\(cueVoice.name) (\(getLanguage(cueVoice.language)))"
    }
    
    func save() {
        let cueVoice = VoiceOptions(
            voiceId: cueVoiceId,
            rate: Float(cueRate),
            pitch: Float(cuePitch),
            volume: Float(cueVolume)
        )
        
        voiceEngine.cueVoiceOptions = cueVoice
        voiceEngine.save()
    }
    
    var body: some View {
        VStack {
            VStack {
                BottomText(
                    topText: AttributedString(
                        localized: "**Cue Voice**",
                        comment: "Label for the cue voice during onboarding"
                    ),
                    bottomText: AttributedString(
                        localized: "The voice that is used to speak information to you. Select the options tht you want to hear when Echo is talking to you.",
                        comment: "Explanation of cuevoice during onboarding"
                    )
                )
            }.padding()
            Form {
                VoiceOptionsArea(
                    title: "",
                    helpText: "",
                    pitch: $cuePitch,
                    rate: $cueRate,
                    volume: $cueVolume,
                    voiceId: $cueVoiceId,
                    voiceName: $cueVoiceName,
                    playSample: {
                        let cueVoice = VoiceOptions(
                            voiceId: cueVoiceId,
                            rate: Float(cueRate),
                            pitch: Float(cuePitch),
                            volume: Float(cueVolume)
                        )
                        voiceEngine.play(String(
                            localized: "Thank you for using Echo, this is your cue voice",
                            comment: "This is text is read aloud by the Text-To-Speech system as a preview"
                        ), voiceOptions: cueVoice)
                    }
                )
            }
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            loadSettings()
            
            if cueVoiceId == "" {
                loadVoices()
            }
        }
        .onDisappear {
            save()
        }
    }
}
