//
//  EditPage.swift
// Echo
//
//  Created by Gavin Henderson on 11/07/2024.
//

import Foundation
import SwiftUI

struct EditPage: View {
    var save: () -> Void
    
    @Environment(Settings.self) var settings: Settings
    
    @StateObject var mainCommunicationPageState = MainCommunicationPageState(disabledSpelling: true)
    
    var body: some View {
        NavigationStack {
            ZStack {
                if settings.showOnScreenArrows {
                    OnScreenArrows(
                        up: { mainCommunicationPageState.userPrevNode() },
                        down: { mainCommunicationPageState.userNextNode() },
                        left: { mainCommunicationPageState.userBack() },
                        right: { mainCommunicationPageState.userClickHovered() }
                    )
                }
                VStack {
                    HStack {
                        GeometryReader { geometry in
                            HorizontalScrollLock(selectedNode: mainCommunicationPageState.hoveredNode, locked: false) {
                                ForEach(mainCommunicationPageState.getLevels()) { currentLevel in
                                    HStack {
                                        ScrollLock(selectedNode: currentLevel.hoveredNode, locked: false) {
                                            ScrollView {
                                                VStack(alignment: .leading) {
                                                    ForEach(currentLevel.nodes) { node in
                                                        HStack {
                                                            if node == mainCommunicationPageState.hoveredNode {
                                                                EditingNode(mainCommunicationPageState: mainCommunicationPageState, node: node)
                                                            } else {
                                                                Button(action: {
                                                                    mainCommunicationPageState.hoverNode(node, shouldScan: false)
                                                                }, label: {
                                                                    Text(node.displayText)
                                                                        .padding()
                                                                        .opacity(currentLevel.last ? 1 : 0.5)
                                                                })
                                                            }
                                                        }.id(node)
                                                    }
                                                }
                                                .padding(.vertical, max(geometry.size.height / 2, 100))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(
            String(
                localized: "Editing Vocabulary: '\(settings.currentVocab?.name ?? "unknown")'",
                comment: "The main navigation title for editing page"
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(String(localized: "Save", comment: "Save button text for saving vocab changes")) {
                    save()
                }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar, .tabBar)
        .onAppear {
            mainCommunicationPageState.loadSettings(settings)            
            mainCommunicationPageState.onAppearEdit()
        }
    }
}
