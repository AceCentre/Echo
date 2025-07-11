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

    var body: some View {
        ScrollViewReader { scrollControl in
            ScrollView([.horizontal]) {
                HStack {
                    content
                        .onChange(of: selectedNode) {
                            // Prevent rapid scroll animations by checking if the node actually changed
                            guard selectedNode != lastSelectedNode else { return }
                            lastSelectedNode = selectedNode

                            // Use a longer animation duration for editing mode to reduce flashing
                            withAnimation(.easeInOut(duration: 0.3)) {
                                scrollControl.scrollTo("FINAL_ID", anchor: .trailing)
                            }
                        }.onAppear {
                            lastSelectedNode = selectedNode
                            scrollControl.scrollTo("FINAL_ID", anchor: .trailing)
                        }
                    ZStack {
                    }
                    .id("FINAL_ID")
                }

            }
            .scrollDisabled(locked)
            .introspect(.scrollView, on: .iOS(.v17)) { scrollView in
                // Use a longer animation duration for editing mode to reduce flashing
                scrollView.setValue(0.3, forKeyPath: "contentOffsetAnimationDuration")
            }
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

    var body: some View {
        ScrollViewReader { scrollControl in
            content
                .onChange(of: selectedNode) {
                    // Prevent rapid scroll animations by checking if the node actually changed
                    guard selectedNode != lastSelectedNode else { return }
                    lastSelectedNode = selectedNode

                    // Use a longer animation duration for editing mode to reduce flashing
                    withAnimation(.easeInOut(duration: 0.3)) {
                        scrollControl.scrollTo(selectedNode, anchor: .center)
                    }
                }.onAppear {
                    lastSelectedNode = selectedNode
                    scrollControl.scrollTo(selectedNode, anchor: .center)
                }.scrollDisabled(locked)
        }
        .introspect(.scrollView, on: .iOS(.v17)) { scrollView in
            // Use a longer animation duration for editing mode to reduce flashing
            scrollView.setValue(0.3, forKeyPath: "contentOffsetAnimationDuration")
        }
    }
}
