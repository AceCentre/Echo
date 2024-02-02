//
//  View.swift
//  Echo
//
//  Created by Gavin Henderson on 03/10/2023.
//

import Foundation
import SwiftUI

extension SwiftUI.View {
    /***
        Note the directions given here refer to the direction of inertia. So 'left' is swiping your finger from right to the left
     */
    func swipe(
        up: @escaping (() -> Void) = {},
        down: @escaping (() -> Void) = {},
        left: @escaping (() -> Void) = {},
        right: @escaping (() -> Void) = {}
    ) -> some SwiftUI.View {
        return self.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width > 0 && abs(value.translation.width) > abs(value.translation.height) {
                    right()
                }
                
                if value.translation.width < 0 && abs(value.translation.width) > abs(value.translation.height) {
                    left()
                }
                
                if value.translation.height > 0 && abs(value.translation.height) > abs(value.translation.width) {
                    down()
                }
                
                if value.translation.height < 0 && abs(value.translation.height) > abs(value.translation.width) {
                    up()
                }
            }))
    }
}

// https://stackoverflow.com/a/67090073/3125540
extension View {
    func border(_ color: Color, width: CGFloat, cornerRadius: CGFloat) -> some View {
        overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(color, lineWidth: width))
    }
}

// https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
