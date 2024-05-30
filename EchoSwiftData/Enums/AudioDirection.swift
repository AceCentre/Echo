//
//  AudioDirection.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 29/05/2024.
//

enum AudioDirection: Int, Codable {
    case left = 1
    case right = 2
    case center = 3
    
    var pan: Float {
        switch self {
        case .left:
            return -1
        case .right:
            return 1
        case .center:
            return 0
        }
    }
}
