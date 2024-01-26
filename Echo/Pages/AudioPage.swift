//
//  AudioPage.swift
//  Echo
//
//  Created by Gavin Henderson on 26/01/2024.
//

import SwiftUI

enum AudioDirection: Int {
    case left = 1
    case right = 2
    case center = 3
    
    var pan: Float {
        switch self {
        case .left:
            return -1
        case .right:
            return 1
        case .center:
            return 0
        }
    }
}

struct DirectionPicker: View {
    var labelText: String
    @Binding var selection: AudioDirection
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(labelText)
            Picker(labelText, selection: $selection, content: {
                Text("Left Channel").tag(AudioDirection.left)
                Text("Right Channel").tag(AudioDirection.right)
            })
            .pickerStyle(.segmented)
        }
    }
}

struct AudioPage: View {
    @EnvironmentObject var voiceEngine: VoiceController
    
    var body: some View {
        Form {
            Section(content: {
                Toggle(isOn: voiceEngine.$splitAudio) {
                    Text("Directional Audio", comment: "Label for directional audio toggle")
                }
                if voiceEngine.splitAudio {
                    DirectionPicker(labelText:
                                        String(
                                            localized: "Cue Voice Direction",
                                            comment: "Label for cue voice audio direction"
                                        ), selection: voiceEngine.$cueDirection)
                    DirectionPicker(labelText:
                                        String(
                                            localized: "Speaking Voice Direction",
                                            comment: "Label for speaking voice audio direction"
                                        ), selection: voiceEngine.$speakDirection)
                }
            }, header: {
                Text(
                    "Audio",
                    comment: "The label for the section about analytics"
                )
            }, footer: {
                Text(
                    """
                    By default the cue voice and the speaking voice will be played out of the same audio device. If you would like them to be sent to different audio devices you can enable audio splitting and send each voice to either the left our right audio channel. You then have to use an audio splitter cable to direct that out.
                    """,
                comment: "A description of why audio splitting exists")
            })
        }
        .navigationTitle(
            String(
                localized: "Audio Settings",
                comment: "The navigation title for the Audio options page"
            )
        )
    }
}

#Preview {
    AudioPage()
}
