//
//  NodeType.swift
//  Echo
//
//  Created by Gavin Henderson on 26/07/2024.
//

import Foundation

enum NodeType: Int, Codable {
    case root, branch, phrase, spelling, back, rootAndSpelling, letter, predictedWord, currentSentence, currentWord, backspace, clear
}
