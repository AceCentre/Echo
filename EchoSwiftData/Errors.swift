//
//  Errors.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 28/05/2024.
//

import Foundation

enum EchoError: LocalizedError {
    case unknown
    case noChildren
    case unhandledNodeType
    case noParent
    case noSiblings
    case invalidNodeIndex
    case hoveredRootNode
    case hoveredInvalidNodeType
    case noHoverNode
    case tooManySettings

    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Error 00: An unknown error occurred. If you don't know why you are seeing this please contact ghenderson@acecentre.org.uk"
        case .noChildren:
            return "Error 01: Your vocabulary is empty"
        case .unhandledNodeType:
            return "Error 03: You clicked an unknown node type"
        case .noParent:
            return "Error 04: This node has no parent"
        case .noSiblings:
            return "Error 05: This node has no siblings"
        case .invalidNodeIndex:
            return "Error 06: You selected an invalid node index"
        case .hoveredRootNode:
            return "Error 07: You cannot hover the root node"
        case .hoveredInvalidNodeType:
            return "Error 08: You hovered an invalid node type"
        case .noHoverNode:
            return "Error 09: No node to hover"
        case .tooManySettings:
            return "Error 10: Too many settings initialised"
        }
    }
}
