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
                
                mainCommunicationPageState.hoverNode(newNode, shouldScan: false)
            }, label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.green)
            })
            
            HStack {
                
                SheetButton(sheetLabel: {
                    Image(systemName: "gear")
                }, sheetContent: {
                    EditNodeSheet(node: node)
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
                
                if node.children?.count == 0 {
                    Button(action: {
                        print("Add next") // TODO
                    }, label: {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.green)
                    })
                } else {
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
                
                mainCommunicationPageState.hoverNode(newNode, shouldScan: false)
            }, label: {
                Image(systemName: "plus.circle")
                    .foregroundStyle(.green)
            })
        }
        .onAppear {
            text = node.displayText
        }
        .onChange(of: text) {
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

