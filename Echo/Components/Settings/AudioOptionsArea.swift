//
//  AudioOptionsArea.swift
// Echo
//
//  Created by Gavin Henderson on 27/06/2024.
//

import Foundation
import SwiftUI


// DirectionPicker removed - audio splitting functionality disabled

struct AudioOptionsArea: View {
    @Environment(Settings.self) var settings: Settings

    var body: some View {
        @Bindable var bindableSettings = settings
        Form {
            Section(content: {
                // Audio splitting functionality has been disabled
                // All audio will be played through both channels (center)
                Text("Audio Output", comment: "Label for audio output information")
                    .foregroundStyle(.secondary)
                Text("Both cue voice and speaking voice will be played through both audio channels.", comment: "Description of current audio behavior")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }, header: {
                Text(
                    "Audio",
                    comment: "The label for the section about analytics"
                )
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
