//
//  Node.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 08/07/2024.
//

import Foundation
import SwiftData

enum NodeType: Int, Codable {
    case root, branch, phrase, spelling, back, rootAndSpelling, letter, predictedWord, currentSentence, currentWord, backspace, clear
}

@Model
class Node {
    @Relationship(inverse: \Node.parent) private var children: [Node]?
    var parent: Node?
    var displayText: String
    var speakText: String
    var type: NodeType
    var cueText: String
    var currentWord: String
    var index: Int?
    
    @Transient
    private var childrenInOrder: [Node]? = nil
    
    init(
        type: NodeType,
        cueText: String? = nil,
        speakText: String? = nil,
        displayText: String? = nil,
        parent: Node? = nil,
        text: String? = nil,
        children: [Node] = [],
        currentWord: String = ""
    ) {
        self.children = []
        self.parent = parent
        
        self.cueText = text ?? "root"
        self.speakText = text ?? "root"
        self.displayText = text ?? "root"
        
        if let unwrappedCueText = cueText {
            self.cueText = unwrappedCueText
        }
        
        if let unwrappedDispalyText = displayText {
            self.displayText = unwrappedDispalyText
        }
        
        if let unwrappedSpeakText = speakText {
            self.speakText = unwrappedSpeakText
        }

        self.type = type
        self.currentWord = currentWord
        
        setChildren(children)
    }
    
    func setChildren(_ children: [Node]) {
        for (index, child) in children.enumerated() {
            child.index = index
        }
        
        self.children = children
        self.childrenInOrder = children.sorted {
            return $0.index ?? 0 < $1.index ?? 0
        }
    }
    
    func getChildren(_ label: String = "unknown") -> [Node]? {
        if childrenInOrder == nil {
            childrenInOrder = children?.sorted {
                return $0.index ?? 0 < $1.index ?? 0
            }
        }
        
        return childrenInOrder
    }
}
