//
//  Node.swift
// Echo
//
//  Created by Gavin Henderson on 08/07/2024.
//

import Foundation
import SwiftData

@Model
class Node: Encodable, Decodable {
    @Relationship(inverse: \Node.parent) var children: [Node]?
    var parent: Node?
    var displayText: String
    var speakText: String
    var type: NodeType
    var cueText: String
    var currentWord: String
    var index: Int?
    
    @Transient
    private var childrenInOrder: [Node]? = nil
    
    enum CodingKeys: String, CodingKey {
        case children
        case displayText
        case speakText
        case type
        case cueText
        case currentWord
    }
    
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
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.children = []
        self.parent = nil
        
        self.displayText = try values.decode(String.self, forKey: .displayText)
        self.speakText = try values.decode(String.self, forKey: .speakText)
        self.type = try values.decode(NodeType.self, forKey: .type)
        self.cueText = try values.decode(String.self, forKey: .cueText)
        self.currentWord = try values.decode(String.self, forKey: .currentWord)
        
        let tempChildren = try values.decode([Node].self, forKey: .children)
        
        self.setChildren(tempChildren)
    }

    public func encode(to encoder: Encoder) throws {        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(self.getChildren(), forKey: .children)
        try container.encode(self.displayText, forKey: .displayText)
        try container.encode(self.speakText, forKey: .speakText)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.cueText, forKey: .cueText)
        try container.encode(self.currentWord, forKey: .currentWord)

    }
    
    func copy() -> Node {
        let copiedChildren = self.children?.map { currentNode in
            return currentNode.copy()
        } ?? []
        
        let newNode = Node(
            type: self.type,
            cueText: self.cueText,
            speakText: self.speakText,
            displayText: self.displayText,
            children: copiedChildren,
            currentWord: self.currentWord
        )
        
        return newNode
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
    
    func addBefore(_ newNode: Node) {
        let siblings = self.parent?.children?.sorted {
            return $0.index ?? 0 < $1.index ?? 0
        }
        
        if var unwrappedSiblings = siblings {
            let newIndex = self.index ?? 0
            unwrappedSiblings.insert(newNode, at: newIndex)
            
            parent?.setChildren(unwrappedSiblings)
            
        }
    }
    
    func addBackNodes(_ backButtonPosition: BackButtonPosition?) {
        if type == .branch {
            let currentChildren = getChildren() ?? []
            let backNode = Node(type: .back, text: "Back")
            
            if backButtonPosition == .top {
                setChildren([backNode] + currentChildren)
            } else if backButtonPosition == .bottom {
                setChildren(currentChildren + [backNode])
            }
            
            for child in (children ?? []) {
                child.addBackNodes(backButtonPosition)
            }
        } else if type == .root {
            for child in (children ?? []) {
                child.addBackNodes(backButtonPosition)
            }
        }
    }
    
    func removeBackNodes() {
        for child in (children ?? []) {
            if child.type == .back {
                _ = child.delete()
            }
            
            child.removeBackNodes()
            
        }
    }
    
    func addAfter(_ newNode: Node) {
        let siblings = self.parent?.children?.sorted {
            return $0.index ?? 0 < $1.index ?? 0
        }
        
        if var unwrappedSiblings = siblings {
            let newIndex = (self.index ?? 0) + 1
            
            unwrappedSiblings.insert(newNode, at: newIndex)
            
            parent?.setChildren(unwrappedSiblings)
            
        }
    }
    
    func unlink() {
        for child in children ?? [] {
            child.unlink()
            
            child.parent = nil
        }
        
        self.setChildren([])
    }
    
    func delete() -> Node? {
        let preDeleteParent = self.parent
        
        unlink()
        
        let siblings = self.parent?.children?.sorted {
            return $0.index ?? 0 < $1.index ?? 0
        } ?? []
        
        
        let siblingsMissingSelf = siblings.filter {
            $0 != self
        }
        
        var newHoverNode: Node? = siblingsMissingSelf.first
        
        for child in siblings {
            if child == self {
                break
            }
            
            newHoverNode = child
        }
        
        self.parent?.setChildren(siblingsMissingSelf)
        
        if let unwrappedHoverNode = newHoverNode {
            return unwrappedHoverNode
        } else {
            preDeleteParent?.type = .phrase
            return preDeleteParent
        }
    }
}
extension Node {
    var details: String {
        """
        Type: \(type), 
        Display Text: \(displayText), 
        Cue Text: \(cueText), 
        Index: \(index ?? -1), 
        Parent Display Text: \(parent?.displayText ?? "None")
        """
    }
}
