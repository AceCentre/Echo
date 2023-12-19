//
//  ControllerButtonSelection.swift
//  Echo
//
//  Created by Gavin Henderson on 18/12/2023.
//

import SwiftUI

struct ControllerButtonSection: View {
    @State var holdAction: Action
    @State var tapAction: Action
    var button: ControllerButton
    
    var body: some View {
        Picker(
            String(
                localized: "Single Tap",
                comment: "The label that is shown next to the single tap action"
            ),
            selection: $tapAction
        ) {
            ForEach(Action.tapCases) { action in
                Text(action.display)
            }
        }.pickerStyle(.menu)
        Picker(
            String(
                localized: "Hold",
                comment: "The label that is shown next to the single hold action"
            ),
            selection: $holdAction
        ) {
            ForEach(Action.holdCases) { action in
                Text(action.display)
            }
        }.pickerStyle(.menu)
        .onChange(of: holdAction) {
            button.holdAction = holdAction
        }
        .onChange(of: tapAction) {
            button.tapAction = tapAction
        }
    }
}
