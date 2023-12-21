//
//  Items.swift
//  Echo
//
//  Created by Gavin Henderson on 02/08/2023.
//

import Foundation
import SwiftUI

class FinishItem: ItemProtocol, Identifiable {
    var id = UUID()
    var displayText: String
    var speakText: String
    var voiceEngine: VoiceEngine
    var letter: String = ""
    
    init(_ display: String, voiceEngine: VoiceEngine) {
        self.displayText = display
        self.speakText = displayText
        self.voiceEngine = voiceEngine
    }

    func select(enteredText: String, cb: @escaping (_ enteredText: String) -> Void) {
        voiceEngine.playSpeaking(enteredText) {
            cb("")
        }
    }
}

class BackspaceItem: ItemProtocol, Identifiable {
    var id = UUID()
    var displayText: String
    var speakText = "Undo"
    var letter: String = ""

    init(_ display: String) {
        self.displayText = display
    }

    func select(enteredText: String, cb: @escaping (_ enteredText: String) -> Void) {
        if enteredText == "" {
            cb("")
            return
        }
        
        // `removeLast` annoyingly mutates the string
        // which means we have to do this copy nonsense
        var mutableCopy = enteredText
        mutableCopy.removeLast()
        cb(mutableCopy)
    }
}

class ClearItem: ItemProtocol, Identifiable {
    var id = UUID()
    var displayText: String = "Clear"
    var speakText = "Clear"
    var letter: String = ""

    func select(enteredText: String, cb: @escaping (_ enteredText: String) -> Void) {
        cb("")
    }
}

enum LetterItemType {
    case letter
    case predictedLetter
    case predictedWord
    case word
}

class LetterItem: ItemProtocol, Identifiable {
    var id = UUID()
    var letter: String
    var displayText: String
    var speakText: String
    
    var letterType: LetterItemType
    
    var analytics: Analytics?
    
    init(_ letter: String, letterType: LetterItemType, analytics: Analytics? = nil) {
        self.letter = letter
        self.displayText = letter
        self.speakText = letter
        self.letterType = letterType
        self.analytics = analytics
    }
    
    init(_ letter: String, display: String, letterType: LetterItemType, analytics: Analytics? = nil) {
        self.letter = letter
        self.displayText = display
        self.speakText = letter
        self.letterType = letterType
        self.analytics = analytics
    }
    
    init(_ letter: String, display: String, speakText: String, letterType: LetterItemType, analytics: Analytics? = nil) {
        self.letter = letter
        self.displayText = display
        self.speakText = speakText
        self.letterType = letterType
        self.analytics = analytics
    }
    
    func select(enteredText: String, cb: @escaping (_ enteredText: String) -> Void) {
        switch letterType {
        case .letter:
            analytics?.letterAdded(isPredicted: false)
        case .predictedLetter:
            analytics?.letterAdded(isPredicted: true)
        case .predictedWord:
            analytics?.wordAdded(isPredicted: true)
        case .word:
            analytics?.wordAdded(isPredicted: false)
        }
        
        cb(enteredText + letter)
    }
}

/// This is protocol of an item.
///
/// The reason this is a protocol is because we will define different types of item for example
/// we will want a 'LetterItem' and maybe a 'SentenceItem' and a 'ActionItem'
protocol ItemProtocol: Identifiable {
    var id: UUID { get }
    var displayText: String { get }
    var speakText: String { get }
    var letter: String { get }
    func select(enteredText: String, cb: @escaping (_ enteredText: String) -> Void)
}

// We need this kinda annoying container due to:
/// https://stackoverflow.com/questions/73773884/any-identifiable-cant-conform-to-identifiable
struct Item: Identifiable {
    var details: any ItemProtocol
    var id: UUID { details.id }
    
    init(letter: String, letterType: LetterItemType, analytics: Analytics? = nil) {
        self.details = LetterItem(letter, letterType: letterType, analytics: analytics)
    }
    
    init(letter: String, display: String, letterType: LetterItemType, analytics: Analytics? = nil) {
        self.details = LetterItem(letter, display: display, letterType: letterType, analytics: analytics)
    }
    
    init(letter: String, display: String, speakText: String, letterType: LetterItemType, analytics: Analytics? = nil) {
        self.details = LetterItem(letter, display: display, speakText: speakText, letterType: letterType, analytics: analytics)
    }

    init(actionType: ItemActionType, display: String, voiceEngine: VoiceEngine) {
        switch actionType {
        case .backspace:
            self.details = BackspaceItem(display)
        case .finish:
            self.details = FinishItem(display, voiceEngine: voiceEngine)
        case .clear:
            self.details = ClearItem()
        }

    }
    
    enum ItemActionType {
        case backspace, finish, clear
    }
}
