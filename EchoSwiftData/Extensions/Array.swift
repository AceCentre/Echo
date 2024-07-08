//
//  Array.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 05/07/2024.
//

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }

        return self[index]
    }
}
