//
//  View.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 24/05/2024.
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
