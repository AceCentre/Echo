//
//  ActionPicker.swift
// Echo
//
//  Created by Gavin Henderson on 04/06/2024.
//

import Foundation
import SwiftUI

struct ActionPickerDestination: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme

    var label: String
    @Binding var selected: SwitchAction
    var actions: [SwitchAction]
    
    var body: some View {
        Form {
            Section(content: {
                ForEach(actions) { action in
                    Button(action: {
                        selected = action
                        dismiss()
                    }, label: {
                        HStack {
                            // I HATE doing a force try. If this markdown is invalid it will crash
                            // However, it would be messy to catch the errors and its a user defined
                            // string, defined at build time so it shouldn't cause crashes. Famous
                            // last words ....
                            let markdownAction = try! AttributedString(
                                markdown: "**\(action.title)** - \(action.description)"
                            )
                            
                            Text(markdownAction)
                                .foregroundStyle(colorScheme == .light ? .black : .white)
                            Spacer()
                            if action.id == selected.id {
                                Image(systemName: "checkmark")
                            }
                        }
                    })
                }
            })
        }
        .navigationTitle(label)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/***
 This is because of the bug: https://stackoverflow.com/questions/77757735/picker-set-to-navigationlink-doesnt-show-any-labels
 */
struct ActionPicker: View {
    var label: String
//    var action: SwitchAction
    var actions: [SwitchAction]

    var actionChange: (SwitchAction) -> Void

    @State var actionState: SwitchAction
    @State private var showingPicker = false


    var body: some View {
        NavigationLink(destination: {
            ActionPickerDestination(
                label: label,
                selected: $actionState,
                actions: actions
            )
        }, label: {
            HStack {
                Text(label)
                Spacer()
                Text(actionState.title)
                    .foregroundStyle(.gray)
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .font(.caption)
            }
        })
        .onAppear {
            // actionState = action
        }
        .onChange(of: actionState) {
            actionChange(actionState)
        }
    }
}
