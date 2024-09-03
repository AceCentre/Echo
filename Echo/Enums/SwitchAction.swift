//
//  SwitchAction.swift
// Echo
//
//  Created by Gavin Henderson on 03/06/2024.
//

import Foundation

enum SwitchAction: String, CaseIterable, Identifiable, Codable {
    case nextNode, prevNode, none, fast, select, goBack, clear, startScanning, goToHome, goToStartOfBranch, pauseScan
    var id: Self { self }
    
    // periphery:ignore
    static public var tapCases: [SwitchAction] = [.nextNode, .prevNode, .none, .select, .goBack, .clear, .startScanning, .goToHome, .goToStartOfBranch, .pauseScan]
    // periphery:ignore
    static public var holdCases: [SwitchAction] = [.nextNode, .prevNode, .none, .fast, .select, .goBack, .clear, .startScanning, .goToHome, .goToStartOfBranch, .pauseScan]

    var title: String {
        switch self {
        case .none: return String(
            localized: "None",
            comment: "Label for action that happens on a keypress"
        )
        case .nextNode: return String(
            localized: "Next",
            comment: "Label for action that happens on a keypress"
        )
        case .prevNode: return String(
            localized: "Previous",
            comment: "Label for action that happens on a keypress"
        )
        case .fast: return String(
            localized: "Quick scan",
            comment: "Label for action that happens on a keypress"
        )
        case .select: return String(
            localized: "Select",
            comment: "Label for action that happens on a keypress"
        )
        case .goBack: return String(
            localized: "Back",
            comment: "Label for action that happens on a keypress"
        )
        case .clear: return String(
            localized: "Clear",
            comment: "Label for action that happens on a keypress"
        )
        case .startScanning: return String(
            localized: "Start scan",
            comment: "Label for action that happens on a keypress"
        )
        case .pauseScan: return String(
            localized: "Pause Scan",
            comment: "Label for action that happens on a keypress"
        )
        case .goToHome: return String(
            localized: "Go to home",
            comment: "Label for action that happens on a keypress"
        )
        case .goToStartOfBranch: return String(
            localized: "Go to start of list",
            comment: "Label for action that happens on a keypress"
        )
        }
    }
    
    var description: String {
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
        case .goBack: return String(
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
        case .pauseScan: return String(
            localized: "Stop automatic scanning on the currently selected node.",
            comment: "Label for action that happens on a keypress"
        )
        case .goToHome: return String(
            localized: "Restarts to the top of the tree, scanning will resume if you have that enabled",
            comment: "Label for action that happens on a keypress"
        )
        case .goToStartOfBranch: return String(
            localized: "Restarts to the top of the current list, scanning will resume if you have that enabled",
            comment: "Label for action that happens on a keypress"
        )
        }
    }
    
}
