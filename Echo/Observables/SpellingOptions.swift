//
//  SpellingOptions.swift
//  Echo
//
//  Created by Gavin Henderson on 18/10/2023.
//

import Foundation
import SwiftUI
import SQLite
import SharedEcho

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

enum ControlCommandDisplayOptions: Int {
    case hide
    case top
    case bottom
}

class SpellingOptions: ObservableObject {
    @AppStorage(StorageKeys.letterPrediction) var letterPrediction: Bool = true
    @AppStorage(StorageKeys.wordPrediction) var wordPrediction: Bool = true
    @AppStorage(StorageKeys.wordPredictionLimit) var wordPredictionLimit: Int = 3
    @AppStorage(StorageKeys.predictionLanguage) var predictionLanguage: String = "DEFAULT"
    @AppStorage(StorageKeys.characterOrder) var characterOrderId: String = CharacterOrder.defaultOrder.id
    @AppStorage(StorageKeys.wordAndLetterPrompt) var wordAndLetterPrompt: Bool = true
    @AppStorage(StorageKeys.appleWordPrediction) var appleWordPrediction: Bool = true
    @AppStorage(StorageKeys.controlCommandPosition) var controlCommandPosition: ControlCommandDisplayOptions = .top
    
    @Published var allWordPrediction: Bool {
        willSet {
            appleWordPrediction = newValue
            wordPrediction = newValue
        }
    }
    
    var dbConn: Connection?
    var wordsTable: SQLite.Table?
    
    var language: PredictionLanguage {
        return PredictionLanguage.allLanguages.first { current in
            if current.id == predictionLanguage {
                return true
            }
            return false
        } ?? .defaultLanguage
    }
    
    var characterOrder: CharacterOrder {
        return CharacterOrder(rawValue: characterOrderId) ?? CharacterOrder.defaultOrder
    }
    
    var currentAlphabet: [String] {
        switch characterOrder {
        case .alphabetical:
            return language.alphabet
        case .frequency:
            return language.frequency
        }
    }
    
    func getAnalyticData() -> [String: Any] {
        return [
            "letterPrediction": letterPrediction,
            "wordPrediction": wordPrediction,
            "wordPredictionLimit": wordPredictionLimit,
            "predictionLanguage": predictionLanguage,
            "characterOrderId": characterOrderId
        ]
    }
    
    init() {
        allWordPrediction = true
        
        if predictionLanguage == "DEFAULT" {
            let usersLanguage: String = Locale.preferredLanguages.first ?? "en"
            
            let defaultLang = PredictionLanguage.allLanguages.first { current in
                return current.acceptedPreferredLangs.contains(usersLanguage)
            }
            
            predictionLanguage = defaultLang?.id ?? PredictionLanguage.defaultLanguage.id
        }
        
        do {
            let path = Bundle.main.path(forResource: "dictionary", ofType: "sqlite")!
            let db = try Connection(path, readonly: true)
            let words = Table("words")
            
            self.dbConn = db
            self.wordsTable = words
            
        } catch {
            print(error)
        }
        
        if wordPrediction || appleWordPrediction {
            allWordPrediction = true
        } else {
            allWordPrediction = false
        }
    }
    
    func getApplePredictionNodes(_ enteredText: String) -> [Node] {
        let predictionText = enteredText.replacingOccurrences(of: "·", with: " ")
        
        if predictionText.last == " " {
            return []
        }
        
        let lastWord = enteredText.components(separatedBy: "·").last ?? ""
        let lastWordRange = NSRange(location: predictionText.utf16.count - lastWord.count, length: lastWord.count)

        let textChecker = UITextChecker()
        
        let completions = textChecker.completions(
            forPartialWordRange: lastWordRange,
            in: predictionText,
            language: Locale.current.language.languageCode?.identifier ?? "en"
        )
                
        return (completions ?? []).map { word in
            return Node(type: .predictedWord, text: word)
        }
    }
    
    func getDictPredictionNodes(_ enteredText: String) -> [Node] {
        guard let db = dbConn else { return [] }
        guard let words = wordsTable else { return [] }
        
        let splitBySpace = enteredText.components(separatedBy: "·")
        
        guard let prefix = splitBySpace.last else {
            return []
        }
        
        if prefix == "" { return [] }
        
        var wordPredictions: [String] = []
        
        do {
            let wordExpression = Expression<String>("word")
            let scoreExpression = Expression<Int>("score")
            let languageExpression = Expression<String>("language")
            
            let query = words
                .filter(languageExpression == language.databaseLanguageCode)
                .filter(wordExpression.like(prefix + "%"))
                .order(scoreExpression.desc)
            
            for word in try db.prepare(query) {
                let nextCharPos = prefix.count
                let unwrappedWord = try word.get(wordExpression)
                
                if nextCharPos < unwrappedWord.count {
                    wordPredictions.append(unwrappedWord)
                }
            }
            
            return wordPredictions.map { word in
                let wordWithoutPrefix = String(word.dropFirst(prefix.count))
                return Node(type: .letter, text: wordWithoutPrefix)
            }
            
        } catch {
            print(error)
            return []
        }
    }
    
    func getDictLetterNodes(_ enteredText: String) -> [Node] {
        var alphabetScores: [String: Int] = [:]
        
        let alphabetItems = currentAlphabet.map { currentPrediction in
            return Node(type: .letter, text: currentPrediction)
        }
        
        guard let db = dbConn else { return alphabetItems }
        guard let words = wordsTable else { return alphabetItems }
        
        let splitBySpace = enteredText.components(separatedBy: "·")
        
        guard let prefix = splitBySpace.last else {
            return alphabetItems
        }
        
        if prefix == "" { return alphabetItems }
        
        do {
            let wordExpression = Expression<String>("word")
            let scoreExpression = Expression<Int>("score")
            let languageExpression = Expression<String>("language")
            
            let query = words
                .filter(languageExpression == language.databaseLanguageCode)
                .filter(wordExpression.like(prefix + "%"))
                .order(scoreExpression.desc)
            
            for word in try db.prepare(query) {
                let nextCharPos = prefix.count
                let unwrappedWord = try word.get(wordExpression)
                let unwrappedScore = try word.get(scoreExpression)
                
                if nextCharPos < unwrappedWord.count {
                    let nextCharIndex = unwrappedWord.index(unwrappedWord.startIndex, offsetBy: nextCharPos)
                    let nextChar = unwrappedWord[nextCharIndex].lowercased()
                    
                    if currentAlphabet.contains(nextChar) {
                        let currentScore = alphabetScores[nextChar, default: 0]
                        alphabetScores[nextChar] = currentScore + unwrappedScore
                    }
                }
            }
            
        } catch {
            print(error)
            return alphabetItems
        }
        
        return currentAlphabet.sorted {
            let firstScore = alphabetScores[$0, default: 0]
            let secondScore = alphabetScores[$1, default: 0]
                            
            return firstScore > secondScore
        }.map { currentPrediction in            
            return Node(type: .letter, text: currentPrediction)
        }
        
    }
    
    func predictNodes(_ enteredText: String) -> [Node] {
        var alphabetItems = currentAlphabet.map { currentPrediction in
            // return Item(letter: currentPrediction, letterType: .letter, analytics: self.analytics)
            return Node(type: .letter, text: currentPrediction)
        }
                
        var words: [Node] = []
        
        if appleWordPrediction {
            words += getApplePredictionNodes(enteredText)
        }
        
        if wordPrediction {
            words += getDictPredictionNodes(enteredText)
        }
        
        words = Array(words.prefix(wordPredictionLimit))
        
        if letterPrediction {
            alphabetItems = getDictLetterNodes(enteredText)
        }
        
        return words + alphabetItems
    }
}
