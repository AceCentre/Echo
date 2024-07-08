//
//  SpeakingVoiceOnboarding.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 30/05/2024.
//

import Foundation
import SwiftUI
import AVKit

struct SpeakingVoiceOnboarding: View {    
    @State var speakingPitch: Double = 0
    @State var speakingVolume: Double = 0
    @State var speakingRate: Double = 0
    @State var speakingVoiceId: String = ""
    @State var speakingVoiceName: String = ""
    
    @Environment(Settings.self) var settings: Settings
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var voiceController = VoiceController()
    
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
                    rate: $speakingRate,
                    volume: $speakingVolume,
                    voiceId: $speakingVoiceId,
                    voiceName: $speakingVoiceName,
                    playSample: {
                        voiceController.playSpeaking(
                            String(
                                localized: "Thank you for using Echo, this is your speaking voice",
                                comment: "This is text is read aloud by the Text-To-Speech system as a preview"
                            )
                        )
                    }
                )
            }
            .scrollContentBackground(.hidden)
        }
        .onAppear {
            if let unwrapped = settings.speakingVoice {
                speakingRate = unwrapped.rate
                speakingVolume = unwrapped.volume
                speakingVoiceId = unwrapped.voiceId
                speakingVoiceName = unwrapped.voiceName
            }
            
            voiceController.loadSettings(settings)
            voiceController.setPhase(scenePhase)
        }
        .onChange(of: speakingRate) {
            settings.speakingVoice?.rate = speakingRate
        }
        .onChange(of: speakingVolume) {
            settings.speakingVoice?.volume = speakingVolume
        }
        .onChange(of: speakingVoiceId) {
            settings.speakingVoice?.voiceId = speakingVoiceId
        }
        .onChange(of: speakingVoiceName) {
            settings.speakingVoice?.voiceName = speakingVoiceName
        }
        .onChange(of: scenePhase) {
            voiceController.setPhase(scenePhase)
        }
    }
}
