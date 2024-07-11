//
//  AudioOptionsArea.swift
// Echo
//
//  Created by Gavin Henderson on 27/06/2024.
//

import Foundation
import SwiftUI


struct DirectionPicker: View {
    var labelText: String
    @Binding var selection: AudioDirection
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(labelText)
            Picker(labelText, selection: $selection, content: {
                Text("Left Channel", comment: "Label for picker of audio channels").tag(AudioDirection.left)
                Text("Right Channel", comment: "Label for picker of audio channels").tag(AudioDirection.right)
            })
            .pickerStyle(.segmented)
        }
    }
}

struct AudioOptionsArea: View {
    @Environment(Settings.self) var settings: Settings

    var body: some View {
        @Bindable var bindableSettings = settings
        Form {
            Section(content: {
                Toggle(isOn: $bindableSettings.splitAudio) {
                    Text("Directional Audio", comment: "Label for directional audio toggle")
                }
                if bindableSettings.splitAudio {
                    DirectionPicker(
                        labelText:
                            String(
                                localized: "Cue Voice Direction",
                                comment: "Label for cue voice audio direction"
                            ),
                        selection: $bindableSettings.cueDirection
                    )
                    DirectionPicker(
                        labelText:
                            String(
                                localized: "Speaking Voice Direction",
                                comment: "Label for speaking voice audio direction"
                            ),
                        selection: $bindableSettings.speakDirection
                    )
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
