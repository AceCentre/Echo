//
//  EditVocabPage.swift
//  Echo
//
//  Created by Gavin Henderson on 19/04/2024.
//

import SwiftUI

struct EditNode: View {
    @EnvironmentObject var items: ItemsList

    var node: Node
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "pencil.line")
                
                VStack {
                    TextField(
                        "Node text",
                        text: .constant(node.displayText)
                    )
                    Color.gray.frame(height: 1 / UIScreen.main.scale)
                }
            }
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            if node.children.isEmpty {
                Button(action: {
                    print("Add")
                    
                }, label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.green)

                })
            } else {
                Button(action: {
                    print("Next")
                    do {
                        try items.expandNode(node)
                    } catch {
                        print("Ruh oh")
                    }
                }, label: {
                    Image(systemName: "chevron.right")
                })
            }
            
        }
    }
}

struct EditVocabPage: View {
    @EnvironmentObject var items: ItemsList

    var body: some View {
        HStack {
            ForEach(items.getLevels(), id: \.self) { currentLevel in
                VStack {
                    ForEach(currentLevel.nodes) { node in
                        HStack {
                            EditNode(node: node)
                        }
                    }
                }
            }
        }.padding(.horizontal)
    }
//        HStack {
//            GeometryReader { geoReader in
//                ScrollView([.horizontal]) {
//                    HStack {
//                        ForEach(items.getLevels(), id: \.self) { currentLevel in
//                            HStack {
//         
//                                    ScrollView {
//                                        VStack(alignment: .leading) {
//                                            ForEach(currentLevel.nodes) { node in
//                                                HStack {
//                                                    TextField(
//                                                        "Node text",
//                                                        text: .constant(node.displayText)
//                                                    )
//                                                    
//                                                    if node.children.count > 0 {
//                                                        Button(action: {
//                                                            print("EXPAND", node)
////                                                            do {
////                                                                try items.expandNode(node)
////                                                            } catch {
////                                                                print("Test")
////                                                            }
//                                                            
//                                                        }, label: {
//                                                            Label("Expand", systemImage: "chevron.right")
//                                                        }).buttonStyle(.bordered)
//                                                    }
////                                                    if node.id == currentLevel.hoveredNode.id {
////                                                        Text(node.displayText)
////                                                            .padding()
////                                                            .bold()
////                                                            .opacity(currentLevel.last ? 1 : 0.5)
////
////                                                    } else {
////                                                        Text(node.displayText)
////                                                            .padding()
////                                                            .opacity(currentLevel.last ? 1 : 0.5)
////
////                                                    }
//                                                }
//                                                
//                                            }
//                                            
//                                        }
//                                        .padding(.vertical, geoReader.size.height/2)
//                                        
//                                    }
//                                    
//                                }
//                            
////                             .frame(maxWidth: geoReader.size.width / 2)
//                        }
//                    }
//                }
//                .scrollDisabled(true)
//                .defaultScrollAnchor(.trailing)
//            }
//        }
//    }
}

#Preview {
    EditVocabPage()
}
