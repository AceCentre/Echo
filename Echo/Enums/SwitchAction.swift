//
//  SwitchAction.swift
// Echo
//
//  Created by Gavin Henderson on 03/06/2024.
//

import Foundation

enum SwitchAction: String, CaseIterable, Identifiable, Codable {
    case nextNode, prevNode, none, fast, select, back, clear, startScanning
    var id: Self { self }
    
    // periphery:ignore
    static public var tapCases: [SwitchAction] = [.nextNode, .prevNode, .none, .select, .back, .clear, .startScanning]
    // periphery:ignore
    static public var holdCases: [SwitchAction] = [.nextNode, .prevNode, .none, .fast, .select, .back, .clear, .startScanning]

    var display: String {
        switch self {
        case .none: return String(
            localized: "None",
            comment: "Label for action that happens on a keypress"
        )
        case .nextNode: return String(
            localized: "Go to the next item",
            comment: "Label for action that happens on a keypress"
        )
        case .prevNode: return String(
            localized: "Go to the previous item",
            comment: "Label for action that happens on a keypress"
        )
        case .fast: return String(
            localized: "Quickly scan through the items",
            comment: "Label for action that happens on a keypress"
        )
        case .select: return String(
            localized: "Select the currently selected item",
            comment: "Label for action that happens on a keypress"
        )
        case .back: return String(
            localized: "Go back to the last level of the vocabulary (or delete the last inputted letter)",
            comment: "Label for action that happens on a keypress"
        )
        case .clear: return String(
            localized: "Clear all the inputted text",
            comment: "Label for action that happens on a keypress"
        )
        case .startScanning: return String(
            localized: "Start scanning from the current item, scanning must be enabled",
            comment: "Label for action that happens on a keypress"
        )
        }
    }
    
}
