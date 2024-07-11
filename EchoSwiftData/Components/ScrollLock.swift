//
//  ScrollLock.swift
//  EchoSwiftData
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
    
    var body: some View {
        ScrollViewReader { scrollControl in
            ScrollView([.horizontal]) {
                HStack {
                    content
                        .onChange(of: selectedNode) {
                            withAnimation {
                                scrollControl.scrollTo("FINAL_ID", anchor: .trailing)
                            }
                        }.onAppear {
                            scrollControl.scrollTo("FINAL_ID", anchor: .trailing)
                        }
                    ZStack {
                    }
                    .id("FINAL_ID")
                }
                
            }
            .scrollDisabled(locked)
            .introspect(.scrollView, on: .iOS(.v17)) { scrollView in
                // We need a shorter animation than default on scrollTo so that it
                // always finishes the animation before the next one starts.
                // There seems to be a bug where `scrollTo` ignores the animation
                // passed into withAnimation. This is why we have to put this hack
                // in to set the 'contentOffsetAnimationDuration' value.
                // https://stackoverflow.com/a/68645170/3125540
                scrollView.setValue(0.1, forKeyPath: "contentOffsetAnimationDuration")
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

    var body: some View {
        ScrollViewReader { scrollControl in
            content
                .onChange(of: selectedNode) {
                    withAnimation {
                        scrollControl.scrollTo(selectedNode, anchor: .center)
                    }
                }.onAppear {
                    scrollControl.scrollTo(selectedNode, anchor: .center)
                }.scrollDisabled(locked)
        }
        .introspect(.scrollView, on: .iOS(.v17)) { scrollView in
            // We need a shorter animation than default on scrollTo so that it
            // always finishes the animation before the next one starts.
            // There seems to be a bug where `scrollTo` ignores the animation
            // passed into withAnimation. This is why we have to put this hack
            // in to set the 'contentOffsetAnimationDuration' value.
            // https://stackoverflow.com/a/68645170/3125540
            scrollView.setValue(0.1, forKeyPath: "contentOffsetAnimationDuration")
        }
    }
}
