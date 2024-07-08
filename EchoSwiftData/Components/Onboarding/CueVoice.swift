//
//  CueVoice.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 29/05/2024.
//

import Foundation

import Foundation
import SwiftUI
import AVFAudio

struct CueVoiceOnboarding: View {
    @State var cueVolume: Double = 0
    @State var cueRate: Double = 0
    @State var cueVoiceId: String = ""
    @State var cueVoiceName: String = ""
    
    @Environment(Settings.self) var settings: Settings
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var voiceController = VoiceController()
    
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
                    rate: $cueRate,
                    volume: $cueVolume,
                    voiceId: $cueVoiceId,
                    voiceName: $cueVoiceName,
                    playSample: {
                        voiceController.playCue(
                            String(
                                localized: "Thank you for using Echo, this is your cue voice",
                                comment: "This is text is read aloud by the Text-To-Speech system as a preview"
                            )
                        )
                    }
                )
            }
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            if let unwrapped = settings.cueVoice {
                cueRate = unwrapped.rate
                cueVolume = unwrapped.volume
                cueVoiceId = unwrapped.voiceId
                cueVoiceName = unwrapped.voiceName
            }
            
            voiceController.loadSettings(settings)
            voiceController.setPhase(scenePhase)
        }
        .onChange(of: cueRate) {
            settings.cueVoice?.rate = cueRate
        }
        .onChange(of: cueVolume) {
            settings.cueVoice?.volume = cueVolume
        }
        .onChange(of: cueVoiceId) {
            settings.cueVoice?.voiceId = cueVoiceId
        }
        .onChange(of: cueVoiceName) {
            settings.cueVoice?.voiceName = cueVoiceName
        }
        .onChange(of: scenePhase) {
            voiceController.setPhase(scenePhase)
        }
        
    }
}
