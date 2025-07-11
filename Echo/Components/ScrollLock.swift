//
//  ScrollLock.swift
// Echo
//
//  Created by Gavin Henderson on 01/07/2024.
//

import Foundation
import SwiftUI
import SwiftUIIntrospect
import SwiftData

struct HorizontalScrollLock<Content: View>: SwiftUI.View {
    var selectedNode: Node?
    var locked: Bool = true

    @ViewBuilder var content: Content
    @State private var lastSelectedNode: Node?
    @State private var scrollWorkItem: DispatchWorkItem?

    var body: some View {
        ScrollViewReader { scrollControl in
            ScrollView([.horizontal]) {
                HStack {
                    content
                        .onChange(of: selectedNode) {
                            // Prevent rapid scroll animations by checking if the node actually changed
                            guard selectedNode != lastSelectedNode else { return }
                            lastSelectedNode = selectedNode

                            // Cancel any pending scroll operation
                            scrollWorkItem?.cancel()

                            // Create new scroll work item
                            let workItem = DispatchWorkItem {
                                scrollControl.scrollTo("FINAL_ID", anchor: .trailing)
                            }

                            scrollWorkItem = workItem
                            DispatchQueue.main.async(execute: workItem)
                        }
                        .onAppear {
                            lastSelectedNode = selectedNode
                            // Immediate scroll on appear
                            scrollControl.scrollTo("FINAL_ID", anchor: .trailing)
                        }
                    ZStack {
                    }
                    .id("FINAL_ID")
                }

            }
            .scrollDisabled(locked)
            // Remove introspect animation to prevent conflicts with instant scrolling
        }
    }
}

/***
    Renders a ScrollView and keeps the given UUID always in the center of the scroll area
 */
struct ScrollLock<Content: View>: SwiftUI.View {
    var selectedNode: Node?
    var locked: Bool = true
    @ViewBuilder var content: Content

    @State private var lastSelectedNode: Node?
    @State private var scrollWorkItem: DispatchWorkItem?

    var body: some View {
        ScrollViewReader { scrollControl in
            content
                .onChange(of: selectedNode) {
                    // Prevent rapid scroll animations by checking if the node actually changed
                    guard selectedNode != lastSelectedNode else { return }

                    lastSelectedNode = selectedNode

                    // Only scroll if we have a valid selectedNode
                    guard let selectedNode = selectedNode else { return }

                    // Cancel any pending scroll operation
                    scrollWorkItem?.cancel()

                    // Create new scroll work item
                    let workItem = DispatchWorkItem {
                        // Double-check that this is still the current selected node
                        guard selectedNode == self.selectedNode else { return }
                        scrollControl.scrollTo(selectedNode, anchor: .center)
                    }

                    scrollWorkItem = workItem
                    DispatchQueue.main.async(execute: workItem)
                }
                .onAppear {
                    lastSelectedNode = selectedNode
                    // Scroll to the selected node on appear, but only if we have one
                    if let selectedNode = selectedNode {
                        scrollControl.scrollTo(selectedNode, anchor: .center)
                    }
                }
                .scrollDisabled(locked)
        }
    }
}
