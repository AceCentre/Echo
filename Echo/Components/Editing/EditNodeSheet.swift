//
//  EditNodeSheet.swift
// Echo
//
//  Created by Gavin Henderson on 11/07/2024.
//

import Foundation
import SwiftUI

struct EditNodeSheet: View {
    @Bindable var node: Node

    @ObservedObject var mainCommunicationPageState: MainCommunicationPageState

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var errorHandling: ErrorHandling
    @Environment(\.modelContext) var modelContext

    @State var showDeleteAlert = false

    @State var isSpelling: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(content: {
                    TextField(String(localized: "Display Text", comment: "Text field placeholder for display text"), text: $node.displayText)
                }, header: {
                    Text("Display Text", comment: "Header for editing display text")
                }, footer: {
                    Text("Text that is displayed in the tree", comment: "Footer for editing display text")
                })
                Section(content: {
                    TextField(String(localized: "Cue Text", comment: "Text field placeholder for cue text"), text: $node.cueText)
                }, header: {
                    Text("Cue Text", comment: "Header for editing cue text")
                }, footer: {
                    Text("Text that is read in the cue voice", comment: "Footer for editing cue text")
                })
                if node.type == .phrase {
                    Section(content: {
                        TextField(String(localized: "Spoken Text", comment: "Text field placeholder for spoken text"), text: $node.speakText)
                    }, header: {
                        Text("Spoken Text", comment: "Header for editing spoken text")
                    }, footer: {
                        Text("Text that is read in the spoken voice when selected", comment: "Footer for editing spoken text")
                    })
                }
                
                Section(content: {
                    Toggle(String(localized: "Spelling mode", comment: "label for toggle around node spelling"), isOn: $isSpelling)
                }, header: {
                    Text("Spelling", comment: "Section title for spelling in node editing")
                }, footer: {
                    Text("Note, if there are children to this node they will be lost if you make it a spelling branch", comment: "Footer for spelling in node editing")
                })
                
                if node.parent?.type != .root || (node.parent?.children?.count ?? 0) > 1 {
                    Section(content: {
                        Button(role: .destructive, action: {
                            showDeleteAlert = true
                        }, label: {
                            Label(String(localized: "Delete Node", comment: "Text on button for deleting a node"), systemImage: "trash")
                                .foregroundColor(.red)
                        })
                        
                        .alert(
                            String(localized: "Delete Node", comment: "Alert title for deleting node"),
                            isPresented: $showDeleteAlert
                        ) {
                            Button(String(localized: "Delete", comment: "Button text for deleting a node"), role: .destructive) {
                                let newHovered = node.delete()
                                
                                do {
                                    try modelContext.save()
                                } catch {
                                    errorHandling.handle(error: error)
                                }
                                
                                if let unwrappedNewNode = newHovered {
                                    mainCommunicationPageState.hoverNode(unwrappedNewNode, shouldScan: false)
                                }
                            }
                            Button("Cancel", role: .cancel) {
                                showDeleteAlert = true
                            }
                        } message: {
                            Text("Be careful about what nodes you delete, if the node has children those will be deleted too. There is no way to restore a node.", comment: "Alert explanation of node deletion")
                        }
                        
                    }, footer: {
                        Text("Be careful about what nodes you delete, if the node has children those will be deleted too. There is no way to restore a node.", comment: "Footer explanation of node deletion")
                    })
                }
                
            }
            .onAppear {
                isSpelling = node.type == .spelling
            }
            .onChange(of: isSpelling) {
                if isSpelling {
                    node.type = .spelling
                } else {
                    let childrenCount = node.children?.count ?? 0

                    if childrenCount > 0 {
                        node.type = .branch
                    } else {
                        node.type = .phrase
                    }
                }
            }
            .navigationTitle("Editing: " + node.displayText)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        do {
                            try modelContext.save()
                            self.presentationMode.wrappedValue.dismiss()
                        } catch {
                            errorHandling.handle(error: error)
                        }
                    }
                }
            }
        }
    }
}
