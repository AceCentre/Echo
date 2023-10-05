//
//  View.swift
//  Echo
//
//  Created by Gavin Henderson on 03/10/2023.
//

import Foundation
import SwiftUI

extension SwiftUI.View {
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