//
//  VoiceSelectionArea.swift
// Echo
//
//  Created by Gavin Henderson on 25/06/2024.
//

import Foundation
import SwiftUI
import AVFAudio

struct VoiceSelectionArea: View {
    @Environment(Settings.self) var settings: Settings
    @Environment(\.scenePhase) var scenePhase
    
    @State var cuePitch: Double = 0
    @State var cueVolume: Double = 0
    @State var cueRate: Double = 0
    @State var cueVoiceId: String = ""
    @State var cueVoiceName: String = ""
    
    @State var speakingPitch: Double = 0
    @State var speakingVolume: Double = 0
    @State var speakingRate: Double = 0
    @State var speakingVoiceId: String = ""
    @State var speakingVoiceName: String = ""

    @StateObject var voiceController = VoiceController()
    
    var body: some View {
        Form {
            VoiceOptionsArea(
                title: String(
                    localized: "Speaking Voice",
                    comment: "The heading for the options that control the speaking voice"
                ),
                helpText: String(
                    localized: "Your speaking voice is the voice that is used to communicate with your communication partner. Select the options that you want to represent your voice.",
                    comment: "The footer for the options that control the speaking voice"
                ),
                rate: $speakingRate,
                volume: $speakingVolume,
                voiceId: $speakingVoiceId,
                voiceName: $speakingVoiceName,
                playSample: {
                    print("🔊 DEBUG: Speaking voice play sample called")
                    voiceController.playSpeaking(
                        String(
                            localized: "Thank you for using Echo, this is your speaking voice",
                            comment: "This is text is read aloud by the Text-To-Speech system as a preview"
                        )
                    )
                    print("🔊 DEBUG: Speaking voice play sample completed")
                }
            )
            VoiceOptionsArea(
                title: String(
                    localized: "Cue Voice",
                    comment: "The heading for the options that control the cue voice"
                ),
                helpText: String(
                    localized: "Your cue voice is the voice that is used to speak information to you. Select the options tht you want to hear when Echo is talking to you.",
                    comment: "The footer for the options that control the cue voice"
                ),
                rate: $cueRate,
                volume: $cueVolume,
                voiceId: $cueVoiceId,
                voiceName: $cueVoiceName,
                playSample: {
                    print("🔊 DEBUG: Cue voice play sample called")
                    voiceController.playCue(
                        String(
                            localized: "Thank you for using Echo, this is your cue voice",
                            comment: "This is text is read aloud by the Text-To-Speech system as a preview"
                        )
                    )
                    // print("🔊 DEBUG: Cue voice play sample completed")
                }
            )
        }
        .onAppear {
            if let unwrapped = settings.speakingVoice {
                speakingRate = unwrapped.rate
                speakingVolume = unwrapped.volume
                speakingVoiceId = unwrapped.voiceId
                speakingVoiceName = unwrapped.voiceName
            }
            
            if let unwrapped = settings.cueVoice {
                cueRate = unwrapped.rate
                cueVolume = unwrapped.volume
                cueVoiceId = unwrapped.voiceId
                cueVoiceName = unwrapped.voiceName
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
        .navigationTitle(
            String(
                localized: "Voice Options",
                comment: "The navigation title for the voice options page"
            )
        )
    }
}
