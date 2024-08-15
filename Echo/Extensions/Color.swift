//
//  Color.swift
//  Echo
//
//  Created by Will Wade on 15/08/2024.
//

import Foundation
import SwiftUI

extension Color {
    static func fromString(_ colorString: String) -> Color {
        switch colorString.lowercased() {
        case "yellow":
            return .yellow
        case "black":
            return .black
        case "red":
            return .red
        case "green":
            return .green
        case "blue":
            return .blue
        default:
            return .black // Default color if string doesn't match
        }
    }
}
