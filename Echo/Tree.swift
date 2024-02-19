//
//  Tree.swift
//  Echo
//
//  Created by Gavin Henderson on 09/02/2024.
//

import Foundation

enum Vocabulary: Int, CaseIterable, Identifiable {
    case basic
    case spelling
    
    var id: String {
        switch self {
        case .basic: return "Basic"
        case .spelling:  return "Spelling"
        }
    }
    
    var tree: Tree {
        switch self {
        case .basic:
            return Tree.Basic
        case .spelling:
            return Tree.SpellingTree
        }
    }
}

enum NodeType {
    case root
    case spelling
    case rootAndSpelling
    case letter
    case predictedWord
    case backspace
    case clear
    case currentWord
    case currentSentence
    case phrase
    case branch
    case back
}

class Node: Identifiable {
    var type: NodeType
    var cueText: String
    var speakText: String
    var displayText: String
    var currentWord: String
    var children: [Node]
    var id: UUID
    var parent: Node?
    
    init(
        type: NodeType,
        text: String = "",
        cueText: String = "",
        speakText: String = "",
        displayText: String = "",
        currentWord: String = "",
        children: [Node] = []
    ) {
        self.type = type
        self.children = children
        self.id = UUID()
        self.parent = nil
        
        self.cueText = cueText
        self.displayText = displayText
        self.currentWord = currentWord
        self.speakText = speakText
        
        if cueText == "" {
            self.cueText = text
        }
        
        if speakText == "" {
            self.speakText = text
        }
        
        if displayText == "" {
            self.displayText = text
        }
        
        if currentWord == "" {
            self.currentWord = text
        }
        
        for child in children {
            child.parent = self
        }
    }
}

class Tree {
    var name: String
    var rootNode: Node
    
    init(
        name: String,
        rootNode: Node
    ) {
        self.name = name
        self.rootNode = rootNode
    }
    
    // periphery:ignore
    public static var Basic = Tree(
        name: "Demo Vocabulary",
        rootNode: Node(type: .root, children: [
            Node(type: .phrase, text: "Hello, welcome to echo"),
            Node(type: .branch, text: "Phrases", children: [
                Node(type: .phrase, text: "Hey"),
                Node(type: .phrase, text: "How are you"),
                Node(type: .phrase, text: "Tell me more"),
                Node(type: .back, text: "Back")
            ]),
            Node(type: .spelling, text: "I will spell it")
        ])
    )
    
    // periphery:ignore
    public static var SpellingTree = Tree(
        name: "Spelling",
        rootNode: Node(type: .rootAndSpelling)
    )
}

/**
 DEMO TREE
 
 Jokes
    Knock Knock
        Tank
            You're Welcome
            Back
        Annie
            Annie way you can let me in
            Back
        Back
 Phrases
    Hey
    How are you
    Tell me more
    Questions
        Whats your name
        Whats your age
        Back
    Back
    I will spell it
        Splling interface
        Back
 */
