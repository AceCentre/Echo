//
//  SpeakingVoiceOnboarding.swift
//  Echo
//
//  Created by Gavin Henderson on 30/10/2023.
//

import Foundation
import SwiftUI
import AVKit

struct SpeakingVoiceOnboarding: View {
    @EnvironmentObject var voiceEngine: VoiceController
    
    @State var speakingPitch: Double = 0
    @State var speakingVolume: Double = 0
    @State var speakingRate: Double = 0
    @State var speakingVoiceId: String = ""
    @State var speakingVoiceName: String = ""
    
    func loadSettings() {
        speakingPitch = Double(voiceEngine.speakingVoiceOptions.pitch)
        speakingVolume = Double(voiceEngine.speakingVoiceOptions.volume)
        speakingRate = Double(voiceEngine.speakingVoiceOptions.rate)
    }
    
    func loadVoices() {
        speakingVoiceId = voiceEngine.speakingVoiceOptions.voiceId
        
        let speakingVoice = AVSpeechSynthesisVoice(identifier: speakingVoiceId) ?? AVSpeechSynthesisVoice()
        
        speakingVoiceName = "\(speakingVoice.name) (\(getLanguage(speakingVoice.language)))"
    }
    
    func save() {
        let speakingVoice = VoiceOptions(
            voiceId: speakingVoiceId,
            rate: Float(speakingRate),
            pitch: Float(speakingPitch),
            volume: Float(speakingVolume)
        )
        
        voiceEngine.speakingVoiceOptions = speakingVoice
        voiceEngine.save()
    }
    
    var body: some View {
        VStack {
            VStack {
                BottomText(
                    topText: AttributedString(
                        localized: "**Speaking Voice**",
                        comment: "Label for the speaking voice during onboarding"
                    ),
                    bottomText: AttributedString(
                        localized: "Your speaking voice is the voice that is used to communicate with your communication partner. Select the options that you want to represent your voice.",
                        comment: "Explanation of speaking voice during onboarding"
                    )
                )
            }.padding()
            Form {
                VoiceOptionsArea(
                    title: "",
                    helpText: "",
                    pitch: $speakingPitch,
                    rate: $speakingRate,
                    volume: $speakingVolume,
                    voiceId: $speakingVoiceId,
                    voiceName: $speakingVoiceName,
                    playSample: {
                        let cueVoice = VoiceOptions(
                            voiceId: speakingVoiceId,
                            rate: Float(speakingRate),
                            pitch: Float(speakingPitch),
                            volume: Float(speakingVolume)
                        )
                        voiceEngine.play(String(
                            localized: "Thank you for using Echo, this is your cue voice",
                            comment: "This is text is read aloud by the Text-To-Speech system as a preview"
                        ), voiceOptions: cueVoice, pan: AudioDirection.center.pan)
                    }
                )
            }
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            loadSettings()
            
            if speakingVoiceId == "" {
                loadVoices()
            }
        }
        .onDisappear {
            save()
        }
    }
}
