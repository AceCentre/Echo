//
//  NodeTreeView.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 08/07/2024.
//

import Foundation
import SwiftUI

struct NodeTreeView: View {
    @Environment(Settings.self) var settings: Settings
    
    @ObservedObject var mainCommunicationPageState: MainCommunicationPageState
    
    var body: some View {
        HStack {
            GeometryReader { geoReader in
                HorizontalScrollLock(selectedUUID: mainCommunicationPageState.hoveredNode.id) {
                    ForEach(mainCommunicationPageState.getLevels(), id: \.self) { currentLevel in
                        
                        HStack {
                            HStack {
                                if currentLevel.last {
                                    Image(systemName: "chevron.right")
                                }
                            }.frame(minWidth: 25)
                            ScrollLock(selectedUUID: currentLevel.hoveredNode.id) {
                                ScrollView {
                                    
                                    VStack(alignment: .leading) {
                                        ForEach(currentLevel.nodes, id: \.self) { node in
                                            
                                            HStack {
                                                if node == currentLevel.hoveredNode {
                                                    Text("\(node.displayText)")
                                                        .padding()
                                                        .bold()
                                                        .opacity(currentLevel.last ? 1 : 0.5)
                                                    
                                                } else {
                                                    Text(node.displayText)
                                                        .padding()
                                                        .opacity(currentLevel.last ? 1 : 0.5)
                                                }
                                            }.id(node.id)
                                        }
                                    }.padding(.vertical, geoReader.size.height / 2)
                                }
                                
                                
                            }
                            
                        }
                        .frame(maxWidth: geoReader.size.width / 2)
                    }
                }
            }
            
        }
        .background(Color("transparent"))
        .contentShape(Rectangle())
        .padding()
        .onAppear {
            mainCommunicationPageState.loadSettings(settings)
            mainCommunicationPageState.onAppear()
        }
    }
}
