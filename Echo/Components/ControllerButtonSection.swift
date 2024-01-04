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
        ActionPicker(
            label: String(
                localized: "Single Tap",
                comment: "The label that is shown next to the single tap action"
            ),
            selected: $tapAction,
            actions: Action.tapCases
        )
        
        ActionPicker(
            label: String(
                localized: "Hold",
                comment: "The label that is shown next to the single hold action"
            ),
            selected: $holdAction,
            actions: Action.holdCases
        )
        .onChange(of: holdAction) {
            button.holdAction = holdAction
        }
        .onChange(of: tapAction) {
            button.tapAction = tapAction
        }
    }
}
