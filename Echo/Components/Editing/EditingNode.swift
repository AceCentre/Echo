//
//  EditingNode.swift
// Echo
//
//  Created by Gavin Henderson on 11/07/2024.
//

import Foundation
import SwiftUI

struct EditingNode: View {
    @ObservedObject var mainCommunicationPageState: MainCommunicationPageState
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var errorHandling: ErrorHandling

    @State var text = ""

    var node: Node

    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                let newNode = Node(
                    type: .phrase,
                    text: "New Phrase"
                )
                
                node.addBefore(newNode)
                
                do {
                    try modelContext.save()
                    // Don't automatically hover new nodes in edit mode to prevent UI instability
                    // mainCommunicationPageState.hoverNode(newNode, shouldScan: false)
                } catch {
                    errorHandling.handle(error: error)
                }
            }, label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.green)
            })
            
            HStack {
                
                SheetButton(sheetLabel: {
                    Image(systemName: "gear")
                }, sheetContent: {
                    EditNodeSheet(node: node, mainCommunicationPageState: mainCommunicationPageState)
                }, onDismiss: {
                    text = node.displayText
                })
                                
                TextField(
                    String(localized: "Edit node display text", comment: "Placeholder for text field"),
                    text: $text
                )
                .focused($isFocused, equals: true)
                .frame(minWidth: 200)
                .textFieldStyle(.roundedBorder)
                .cornerRadius(6)
                
                if node.type == .phrase {
                    Button(action: {
                        let newNode = Node(
                            type: .phrase,
                            text: "New Phrase"
                        )
                        
                        node.setChildren([newNode])
                        node.type = .branch
                        
                        do {
                            try modelContext.save()
                            // Don't automatically hover new nodes in edit mode to prevent UI instability
                            // mainCommunicationPageState.hoverNode(newNode, shouldScan: false)
                        } catch {
                            errorHandling.handle(error: error)
                        }
                        
                    }, label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.green)
                    })
                } else if node.type == .branch {
                    Button(action: {
                        mainCommunicationPageState.userClickHovered()
                    }, label: {
                        Image(systemName: "chevron.right")
                    })
                }
            }
            
            Button(action: {
                let newNode = Node(
                    type: .phrase,
                    text: "New Phrase"
                )
                
                node.addAfter(newNode)
                
                do {
                    try modelContext.save()
                    // Don't automatically hover new nodes in edit mode to prevent UI instability
                    // mainCommunicationPageState.hoverNode(newNode, shouldScan: false)
                } catch {
                    errorHandling.handle(error: error)
                }
            }, label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.green)
            })
        }
        .onAppear {
            text = node.displayText
        }
        .onDisappear {
            // View cleanup if needed
        }
        .onChange(of: text) {
            // Update node properties directly without debouncing
            if node.displayText == node.cueText && node.displayText == node.speakText {
                node.displayText = text
                node.cueText = text
                node.speakText = text
            } else if node.displayText == node.cueText {
                node.displayText = text
                node.cueText = text
            } else if node.displayText == node.speakText {
                node.speakText = text
                node.cueText = text
            } else {
                node.displayText = text
            }
        }
        .padding(8)
        .background(.lightGray)
        .cornerRadius(6)
        .shadow(radius: 5)
        .padding(8)
        
    }
}

