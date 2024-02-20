//
//  ItemsList.swift
//  Echo
//
//  Created by Gavin Henderson on 03/10/2023.
//

import Foundation
import SwiftUI
import SharedEcho

/*
 
 Internally class uses the term 'click' and 'hover', i find them less ambgious that 'select'.
 
 The item that is highlighted is currently 'hovered'
 When an item is selected via an access method we 'click' it.
 
 */
// swiftlint:disable type_body_length
class ItemsList: ObservableObject {
    @Published var hoveredNode: Node
    @Published var enteredText = ""
    @Published var scanLoops = 0
        
    @AppStorage(StorageKeys.vocabulary) var vocabulary: Vocabulary = .adultStarter
    @AppStorage(StorageKeys.history) var history: Int = 2
        
    var disableScanningAsHidden = false
    
    var voiceEngine: VoiceController?
    var spelling: SpellingOptions?
    var scanningOptions: ScanningOptions?
    var errorHandling: ErrorHandling?
    
    var workItem: DispatchWorkItem?
    
    var isFastScan: Bool = false
    
    init() {
        hoveredNode = Node(type: .root)
    }
    
    struct Level: Hashable, Equatable {
        static func == (lhs: ItemsList.Level, rhs: ItemsList.Level) -> Bool {
            return lhs.hoveredNode.id == rhs.hoveredNode.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(hoveredNode.id)
            for node in nodes {
                hasher.combine(node.id)
            }
        }
        
        var hoveredNode: Node
        var nodes: [Node]
        var last: Bool
    }
    
    func getLevels() -> [Level] {
        var levels: [Level] = []
        
        var temp = hoveredNode
        
        var last = true
        while temp.id != vocabulary.tree.rootNode.id {
            guard let parent = temp.parent else {
                break
            }
                        
            levels.append(
                Level(
                    hoveredNode: temp,
                    nodes: parent.children,
                    last: last
                )
            )
            last = false

            temp = parent
        }
        
        levels.reverse()
        
        return levels.suffix(history)
    }
    
    func doAction(action: Action) {
        switch action {
        case .none:
            print("No action")
        case .nextNode:
            userNextNode()
        case .prevNode:
            userPrevNode()
        case .select:
            userClickHovered()
        case .fast:
             userStartFastScan()
        case .clear:
            userClear()
        case .back:
            userBack()
        case .startScanning:
            userStartScanning()
        }
    }
    
    func onDisappear() {
        scanLoops = 0
        disableScanningAsHidden = true
        voiceEngine?.stop()
        if let unwrappedWorkItem = workItem {
            unwrappedWorkItem.cancel()
        }
    }
    
    func onAppear() {
        scanLoops = 0
        disableScanningAsHidden = false
        do {
            try clickNode(vocabulary.tree.rootNode, isStartup: true)
        } catch {
            self.errorHandling?.handle(error: error)
        }
    }
    
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    private func clickNode(_ node: Node, isStartup: Bool) throws {
        if let unwrappedWorkItem = workItem {
            unwrappedWorkItem.cancel()
        }
        
        var shouldScan = scanningOptions?.scanAfterSelection ?? false
        if isStartup {
            shouldScan = scanningOptions?.scanOnAppLaunch ?? false
        }
                
        // If you 'click' the root node then we hover on its first child
        if node.type == .root {
            if let firstNode = node.children.first {
                hoverNode(firstNode, shouldScan: shouldScan)
            } else {
                errorHandling?.handle(error: EchoError.noChildren)
            }
        } else if node.type == .phrase {
            voiceEngine?.playSpeaking(node.speakText, cb: {
                do {
                    try self.clickNode(self.vocabulary.tree.rootNode, isStartup: false)
                } catch {
                    self.errorHandling?.handle(error: error)
                }
                
            })
            
        } else if node.type == .branch {
            hoverNode(node.children.first ?? hoveredNode, shouldScan: shouldScan)
        } else if node.type == .rootAndSpelling {
            let nodeToHover = try resetSpellingNodes(parentNode: node)
            hoverNode(nodeToHover, shouldScan: shouldScan)
        } else if node.type == .back {
            if let parentNode = node.parent {
                hoverNode(parentNode, shouldScan: shouldScan)
            }
        } else if node.type == .predictedWord {
            var words = enteredText.components(separatedBy: "·")
            
            if !words.isEmpty {
                words.removeLast()
            }
            
            let allWords = words + [node.displayText]
            
            enteredText = allWords.joined(separator: "·") + "·"
            
            let nodeToHover = try resetSpellingNodes(parentNode: node.parent)
            hoverNode(nodeToHover, shouldScan: shouldScan)
        } else if node.type == .spelling {
            let nodeToHover = try resetSpellingNodes(parentNode: node)
            hoverNode(nodeToHover, shouldScan: shouldScan)
        } else if node.type == .letter {
            enteredText += node.displayText
            
            let nodeToHover = try resetSpellingNodes(parentNode: node.parent)
            
            hoverNode(nodeToHover, shouldScan: shouldScan)
        } else if node.type == .currentSentence {
            voiceEngine?.playSpeaking(node.speakText, cb: {
                self.enteredText = ""
                do {
                    try self.clickNode(self.vocabulary.tree.rootNode, isStartup: false)
                } catch {
                    self.errorHandling?.handle(error: error)
                }
            })
        } else if node.type == .currentWord {
            var words = enteredText.components(separatedBy: "·")
            
            if !words.isEmpty {
                words.removeLast()
            }
            
            let allWords = words + [node.currentWord]
            
            enteredText = allWords.joined(separator: "·") + "·"
            
            let nodeToHover = try resetSpellingNodes(parentNode: node.parent)
            hoverNode(nodeToHover, shouldScan: shouldScan)
        } else if node.type == .backspace {
            if !enteredText.isEmpty {
                enteredText.removeLast()
            }
            
            let nodeToHover = try resetSpellingNodes(parentNode: node.parent)
            hoverNode(nodeToHover, shouldScan: shouldScan)
        } else if node.type == .clear {
            enteredText = ""
            
            let nodeToHover = try resetSpellingNodes(parentNode: node.parent)
            hoverNode(nodeToHover, shouldScan: shouldScan)
        } else {
            errorHandling?.handle(error: EchoError.unhandledNodeType)
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
    
    private func resetSpellingNodes(parentNode: Node?) throws -> Node {
        var spellingNodes = getAllSpellingNodes()
        
        let currentSentenceNode = getCurrentSentenceNode()
        let currentWordNode = getCurrentWordNode()
        
        if parentNode?.type != .rootAndSpelling {
            spellingNodes.append(Node(type: .back, text: "Back"))
        }
        
        if spelling?.controlCommandPosition == .bottom {
            spellingNodes.append(Node(type: .backspace, text: "Undo"))
            spellingNodes.append(Node(type: .clear, text: "Clear"))
        } else if spelling?.controlCommandPosition == .top {
            spellingNodes.insert(Node(type: .backspace, text: "Undo"), at: 0)
            spellingNodes.insert(Node(type: .clear, text: "Clear"), at: 0)
        }
        
        if let unwrappedCurrentWordNode = currentWordNode {
            spellingNodes.insert(unwrappedCurrentWordNode, at: 0)
        }
        
        if let unwrappedSentenceWordNode = currentSentenceNode {
            spellingNodes.insert(unwrappedSentenceWordNode, at: 0)
        }
        
        guard let parent = parentNode else {
            // errorHandling?.handle(error: EchoError.noParent)
            throw EchoError.noParent
        }
        
        for spellingNode in spellingNodes {
            spellingNode.parent = parent
        }
        
        parent.children = spellingNodes
        
        var nodeToHover: Node? = parent.children.first
        
        nodeToHover = parent.children.first
        
        if let unwrappedSentenceWordNode = currentSentenceNode {
            nodeToHover = unwrappedSentenceWordNode
        }
        
        if let unwrappedCurrentWordNode = currentWordNode {
            nodeToHover = unwrappedCurrentWordNode
        }
        
        if let finalNodeToHover = nodeToHover {
            return finalNodeToHover
        } else {
            throw EchoError.noHoverNode
        }
        
    }
    
    private func getCurrentWordNode() -> Node? {
        let wordAndLetterPrompt = self.spelling?.wordAndLetterPrompt ?? true

        let currentWordPrefix = wordAndLetterPrompt ? String(
            localized: "Current Word: ",
            comment: "This label prefixes the current word in the scrollable area. Make sure to leave the colon and space"
        ) : ""
        let splitBySpace = self.enteredText.components(separatedBy: "·")
        let prefix = splitBySpace.last ?? ""
        let prefixWithHyphens = currentWordPrefix + "<say-as interpret-as=\"characters\">\(prefix)</say-as>"
        var currentWordNode: Node?
        if prefix.count > 0 {
            currentWordNode = Node(type: .currentWord, cueText: prefixWithHyphens, displayText: currentWordPrefix + prefix, currentWord: prefix)
            return currentWordNode
        }
        return nil
    }
    
    private func getCurrentSentenceNode() -> Node? {
        let wordAndLetterPrompt = self.spelling?.wordAndLetterPrompt ?? true

        let currentSentencePrefix = wordAndLetterPrompt ? String(
            localized: "Current Sentence: ",
            comment: "This label prefixes the current full sentance in the scrollable area. Make sure to leave the colon and space"
        ) : ""
        let finishedText = currentSentencePrefix + self.enteredText
        var currentSentenceNode: Node?
        if enteredText != "" {
            currentSentenceNode = Node(type: .currentSentence, cueText: finishedText, speakText: self.enteredText, displayText: finishedText)
            return currentSentenceNode
        }
        return nil
    }
    
    private func getAllSpellingNodes() -> [Node] {
        guard let unwrappedSpelling = spelling else {
            return []
        }
        
        let spellingNodes = unwrappedSpelling.predictNodes(enteredText)
        
        return spellingNodes
    }
    
    func userClickHovered() {
        scanLoops = 0
        
        do {
            try clickNode(hoveredNode, isStartup: false)
        } catch {
            errorHandling?.handle(error: error)
        }
    }
    
    func userStartFastScan() {
        scanLoops = 0
                
        do {
            try self.startFastScan()
        } catch {
            self.errorHandling?.handle(error: error)
        }
    }
    
    func userClear() {
        scanLoops = 0
        let scanAfterSelection = scanningOptions?.scanAfterSelection ?? false

        if let parentNode = hoveredNode.parent, parentNode.type == .spelling || parentNode.type == .rootAndSpelling {
            enteredText = ""
            
            do {
                let nodeToHover = try resetSpellingNodes(parentNode: parentNode)
                hoverNode(nodeToHover, shouldScan: scanAfterSelection)
            } catch {
                errorHandling?.handle(error: error)
            }
        }
    }
    
    func userBack() {
        scanLoops = 0
        let scanAfterSelection = scanningOptions?.scanAfterSelection ?? false

        // If there is no text go up tree
        // If there is text, delete a character
        if enteredText == "" {
            if let parentNode = hoveredNode.parent {
                if let firstNode = parentNode.children.first, parentNode.type == .rootAndSpelling || parentNode.type == .root {
                    hoverNode(firstNode, shouldScan: scanAfterSelection)
                } else {
                    hoverNode(parentNode, shouldScan: scanAfterSelection)
                }
            }
        } else {
            enteredText.removeLast()
            do {
                let nodeToHover = try resetSpellingNodes(parentNode: hoveredNode.parent)
                hoverNode(nodeToHover, shouldScan: scanAfterSelection)
            } catch {
                errorHandling?.handle(error: error)
            }
        }
    }
    
    func userStartScanning() {
        scanLoops = 0
        
        self.hoverNode(hoveredNode, shouldScan: true)
    }
    
    func userPrevNode() {
        scanLoops = 0
        
        do {
            try self.prevNode()
        } catch {
            errorHandling?.handle(error: error)
        }
    }
    
    func userNextNode() {
        scanLoops = 0
        
        do {
            try self.nextNode()
        } catch {
            errorHandling?.handle(error: error)
        }
    }
    
    private func nextNodeIndex() throws -> Int {
        guard let siblings = hoveredNode.parent?.children else {
            throw EchoError.noSiblings
        }
        
        let currentIndex = siblings.firstIndex(where: { $0.id == hoveredNode.id }) ?? -1
        let nextIndex = (Int(currentIndex) + 1) % siblings.count
        
        return nextIndex
    }
    
    private func nextNode() throws {
        if let unwrappedWorkItem = workItem {
            unwrappedWorkItem.cancel()
        }
        
        guard let siblings = hoveredNode.parent?.children else {
            throw EchoError.noSiblings
        }
        
        let nextIndex = try nextNodeIndex()
        
        guard let nextNode = siblings[safe: nextIndex] else {
            throw EchoError.invalidNodeIndex
        }
        
        hoverNode(nextNode, shouldScan: true)
    }
    
    private func prevNode() throws {
        if let unwrappedWorkItem = workItem {
            unwrappedWorkItem.cancel()
        }
        
        guard let siblings = hoveredNode.parent?.children else {
            throw EchoError.noSiblings
        }
        
        let currentIndex = siblings.firstIndex(where: { $0.id == hoveredNode.id }) ?? -1
        var nextIndex = (Int(currentIndex) - 1)
        
        if nextIndex < 0 {
            nextIndex = siblings.count + nextIndex
        }
        
        guard let prevNode = siblings[safe: nextIndex] else {
            throw EchoError.invalidNodeIndex
        }
        
        hoverNode(prevNode, shouldScan: true)
    }
    
    private func hoverNode(_ node: Node, shouldScan: Bool) {
        hoveredNode = node
        
        guard let unwrappedVoice = voiceEngine else {
            return
        }
        
        if node.type == .root {
            // Do nothing
            errorHandling?.handle(error: EchoError.hoveredRootNode)
        } else if
            node.type == .phrase ||
            node.type == .branch ||
            node.type == .phrase ||
            node.type == .spelling ||
            node.type == .back ||
            node.type == .letter ||
            node.type == .predictedWord ||
            node.type == .currentSentence ||
            node.type == .currentWord ||
            node.type == .backspace ||
            node.type == .clear
        {
            if isFastScan {
                unwrappedVoice.playFastCue(hoveredNode.cueText, cb: {
                    do {
                        try self.nextNode()
                    } catch {
                        self.errorHandling?.handle(error: error)
                    }
                })
            } else {
                unwrappedVoice.playCue(hoveredNode.cueText, cb: {
                    if self.scanningOptions?.scanning == true && shouldScan {
                        do {
                            try self.setNextMoveTimer()
                        } catch {
                            self.errorHandling?.handle(error: error)
                        }
                    }
                })
            }
        } else {
            errorHandling?.handle(error: EchoError.hoveredInvalidNodeType)
        }
    }
    
    func loadEngine(_ voiceEngine: VoiceController) {
        self.voiceEngine = voiceEngine
    }
    
    func loadSpelling(_ spellingOptions: SpellingOptions) {
        self.spelling = spellingOptions
    }
    
    func loadScanning(_ scanning: ScanningOptions) {
        self.scanningOptions = scanning
    }
    
    func loadErrorHandling(_ errorHandling: ErrorHandling) {
        self.errorHandling = errorHandling
    }
    
    private func setNextMoveTimer() throws {
        if disableScanningAsHidden { return }
        
        let maxScanLoops = scanningOptions?.scanLoops ?? 0
        
        let newWorkItem = DispatchWorkItem(block: {
            do {
                try self.nextNode()
            } catch {
                self.errorHandling?.handle(error: error)
            }
        })
        
        workItem = newWorkItem
        let timeInterval = scanningOptions?.scanWaitTime ?? 3
        
        let nextIndex = try nextNodeIndex()
        
        if nextIndex == 0 {
            scanLoops += 1
        }
        
        if scanLoops < maxScanLoops {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval, execute: newWorkItem)
        }
    }
    
    private func startFastScan() throws {
        if let unwrappedWorkItem = workItem {
            unwrappedWorkItem.cancel()
        }
        
        isFastScan = true
        
        try nextNode()
    }
    
    func stopFastScan() {
        isFastScan = false
    }
}
// swiftlint:enable type_body_length
