//
//  EditVocabPage.swift
//  Echo
//
//  Created by Gavin Henderson on 19/04/2024.
//

import SwiftUI

struct EditVocabPage: View {
    @EnvironmentObject var items: ItemsList
    @EnvironmentObject var accessOptions: AccessOptions
    @EnvironmentObject var spelling: SpellingOptions
    @EnvironmentObject var analytics: Analytics
    
    var body: some SwiftUI.View {
        ZStack {
            
            OnScreenArrows(
                up: { items.userPrevNode() },
                down: { items.userNextNode() },
                left: { items.userBack() },
                right: { items.userClickHovered() }
            )
            
            VStack {
                
                HStack {
                    
                    GeometryReader { geoReader in
                        HorizontalScrollLock(selectedUUID: items.hoveredNode.id, locked: false) {
                            
                                ForEach(items.getLevels(), id: \.self) { currentLevel in
                                    HStack {
                                        
                                        ScrollLock(selectedUUID: currentLevel.hoveredNode.id, locked: false) {
                                            ScrollView {
                                                VStack(alignment: .leading) {
                                                    ForEach(currentLevel.nodes) { node in
                                                        HStack {
                                                            if node.id == items.hoveredNode.id {
                                                                VStack {
                                                                    Button(action: {
                                                                        print("Add above")
                                                                    }, label: {
                                                                        Image(systemName: "plus.circle")
                                                                            .foregroundStyle(.green)
                                                                    })
                                                                    
                                                                    HStack {
                                                                        VStack {
                                                                            TextField(
                                                                                "temp",
                                                                                text: .constant(node.displayText)
                                                                            )
                                                                            Color.gray.frame(height: 1)
                                                                            
                                                                        }
                                                                        .padding()
                                                                        .background(.red)
                                                                        .cornerRadius(6)
                                                                        .padding()
                                                                        
                                                                        if node.children.count == 0 {
                                                                            Button(action: {
                                                                                print("Add next")
                                                                            }, label: {
                                                                                Image(systemName: "plus.circle")
                                                                                    .foregroundStyle(.green)
                                                                            })
                                                                        } else {
                                                                            Button(action: {
                                                                                print("Add next")
                                                                            }, label: {
                                                                                Image(systemName: "chevron.right")
                                                                            })
                                                                        }
                                                                    }
                                                                    
                                                                    Button(action: {
                                                                        print("Add below")
                                                                    }, label: {
                                                                        Image(systemName: "plus.circle")
                                                                            .foregroundStyle(.green)
                                                                    })
                                                                }
                                                                
                                                                
                                                                
                                                                
                                                            } else {
                                                                Button(action: {
                                                                    print("Pressed")
                                                                    items.hoverNode(node, shouldScan: false)
                                                                }, label: {
                                                                    Text(node.displayText)
                                                                        .padding()
                                                                        .opacity(currentLevel.last ? 1 : 0.5)
                                                                })
                                                                
                                                                
                                                            }
                                                        }.id(node.id)
                                                        
                                                    }
                                                }.padding(.vertical, geoReader.size.height/2)
                                                
                                            }
                                            
                                        }
                                    }
                                    .frame(maxWidth: geoReader.size.width / 2)
                                }
                            
                        }
                    }
                }
                
                
            }
            
        }
        
        .accessibilityRepresentation(representation: {
            Text(
                "Echo does not currently support system accessibility controls. To use Echo please disable your system accessibility controls. We hope to improve this in the future.",
                comment: "An explaination to users using Voice over about how to use Echo"
            )
        })
        
        
        
        .navigationTitle(
            String(
                localized: "Echo: Auditory Scanning",
                comment: "The main navigation title for the whole app"
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { /// TODO Not really a fan of this button placement
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: {
                    EditVocabPage()
                }, label: {
                    Image(systemName: "square.and.pencil").foregroundColor(.blue)
                })
            }
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(destination: {
                    SettingsPage()
                }, label: {
                    Image(systemName: "slider.horizontal.3").foregroundColor(.blue)
                })
                
            }
        }
        .toolbarBackground(.visible, for: .navigationBar, .tabBar)
        
        
        
    }
    
}

#Preview {
    EditVocabPage()
}
