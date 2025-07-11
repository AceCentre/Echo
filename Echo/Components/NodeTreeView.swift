//
//  NodeTreeView.swift
//  Echo
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
                    ForEach(mainCommunicationPageState.getLevels()) { currentLevel in
                        
                        HStack {
                            HStack {
                                if currentLevel.last {
                                    Image(systemName: "chevron.right")
                                }
                            }.frame(minWidth: 25)
                            
                            ScrollLock(selectedNode: currentLevel.hoveredNode) {
                                ScrollView {
                                    
                                    VStack(alignment: .leading) {
                                        ForEach(currentLevel.nodes) { node in
                                            
                                            HStack {
                                                if node == currentLevel.hoveredNode {
                                                    let highlightColorOption = ColorOption.colorFromName(settings.highlightColor)
                                                    
                                                    Text("\(node.displayText)")
                                                        .padding()
                                                        .foregroundColor(
                                                            highlightColorOption.color
                                                        )
                                                        .font(
                                                            .custom(
                                                                settings.highlightFontName,
                                                                size: settings.useCustomHighlightFontSize
                                                                ? CGFloat(settings.highlightFontSize)
                                                                : UIFont.preferredFont(forTextStyle: .body).pointSize
                                                            )
                                                        )
                                                        .fontWeight(settings.isHighlightTextBold ? .bold : .regular)
                                                        .opacity(settings.highlightOpacity)
                                                    ///currentLevel.last ? 1 : 0.5) used to be this. I could be making this worse by dropping this.
                                                    
                                                } else {
                                                    let entriesColorOption = ColorOption.colorFromName(settings.entriesColor)
                                                    
                                                    Text(node.displayText)
                                                        .padding()
                                                        .foregroundColor(
                                                            entriesColorOption.color
                                                        )
                                                        .font(
                                                            .custom(
                                                                settings.entriesFontName,
                                                                size: settings.useCustomEntriesFontSize
                                                                ? CGFloat(settings.entriesFontSize)
                                                                : UIFont.preferredFont(forTextStyle: .body).pointSize
                                                            )
                                                        )
                                                        .opacity(settings.entriesOpacity)
                                                }
                                            }.id(node)
                                        }
                                    }
                                    // Move verticalPadding definition here
                                    .padding(.vertical, geoReader.size.height > 0 ? geoReader.size.height / 2 : 0)
                                }
                            }
                        }
                        .frame(maxWidth: geoReader.size.width > 0 ? geoReader.size.width / 2 : .infinity)
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
