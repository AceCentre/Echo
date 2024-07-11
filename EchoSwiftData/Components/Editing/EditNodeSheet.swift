//
//  EditNodeSheet.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 11/07/2024.
//

import Foundation
import SwiftUI

struct EditNodeSheet: View {
    var node: Node
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    
    var body: some View {
        @Bindable var bindableNode = node
        NavigationStack {
            Form {
                Section(content: {
                    TextField(String(localized: "Display Text", comment: "Text field placeholder for display text"), text: $bindableNode.displayText)
                }, header: {
                    Text("Display Text", comment: "Header for editing display text")
                }, footer: {
                    Text("Text that is displayed in the tree", comment: "Footer for editing display text")
                })
                Section(content: {
                    TextField(String(localized: "Cue Text", comment: "Text field placeholder for cue text"), text: $bindableNode.cueText)
                }, header: {
                    Text("Cue Text", comment: "Header for editing cue text")
                }, footer: {
                    Text("Text that is read in the cue voice", comment: "Footer for editing cue text")
                })
                if node.type == .phrase {
                    Section(content: {
                        TextField(String(localized: "Spoken Text", comment: "Text field placeholder for spoken text"), text: $bindableNode.speakText)
                    }, header: {
                        Text("Spoken Text", comment: "Header for editing spoken text")
                    }, footer: {
                        Text("Text that is read in the spoken voice when selected", comment: "Footer for editing spoken text")
                    })
                }
            }
            .navigationTitle("Editing: " + node.displayText)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
