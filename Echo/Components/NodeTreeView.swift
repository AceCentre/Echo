//
//  NodeTreeView.swift
// Echo
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
                HorizontalScrollLock(selectedNode: mainCommunicationPageState.hoveredNode) {
                    ForEach(mainCommunicationPageState.getLevels(), id: \.self) { currentLevel in
                        
                        HStack {
                            HStack {
                                if currentLevel.last {
                                    Image(systemName: "chevron.right")
                                }
                            }.frame(minWidth: 25)
                            ScrollLock(selectedNode: currentLevel.hoveredNode) {
                                ScrollView {
                                    
                                    VStack(alignment: .leading) {
                                        ForEach(currentLevel.nodes, id: \.self) { node in
                                            
                                            HStack {
                                                if node == currentLevel.hoveredNode {
                                                    let highlightColorOption = ColorOption.colorFromName(settings.highlightColor)
                                                    
                                                    Text("\(node.displayText)")
                                                        .padding()
                                                        .foregroundColor(
                                                            highlightColorOption.color
                                                                )
                                                        .fontWeight(settings.isHighlightTextBold ? .bold : .regular)
                                                        .opacity(settings.highlightOpacity)
                                                    //currentLevel.last ? 1 : 0.5) used to be this. I could be making this worse by dropping this.
                                                    
                                                } else {
                                                    let entriesColorOption = ColorOption.colorFromName(settings.entriesColor)
                                                    
                                                    Text(node.displayText)
                                                        .padding()
                                                        .foregroundColor(
                                                            entriesColorOption.color
                                                                )
                                                        .opacity(settings.entriesOpacity)
                                                    //.opacity(currentLevel.last ? 1 : 0.5)
                                                }
                                            }.id(node)
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
