//
//  CharacterOrder.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 30/05/2024.
//

enum CharacterOrder: String, CaseIterable, Identifiable {
    case alphabetical
    case frequency
    
    var id: String {
        switch self {
        case .alphabetical: return "alphabetical"
        case .frequency: return "frequency"
        }
    }
    
    var display: String {
        switch self {
        case .alphabetical: return String(
            localized: "Alphabetical Order",
            comment: "The value for the order of the alphabet"
        )
        case .frequency: return String(
            localized: "Frequency Order",
            comment: "The value for the order of the alphabet"
        )
        }
    }
    
    // periphery:ignore
    public static var defaultOrder: CharacterOrder = .alphabetical
}
