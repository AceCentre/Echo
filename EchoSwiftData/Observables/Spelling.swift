//
//  Spelling.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 05/07/2024.
//

import Foundation
import SQLiteSwift
import SwiftUI

class Spelling: ObservableObject {
    var dbConn: Connection?
    var wordsTable: SQLiteSwift.Table?
    
    var settings: Settings?
    
    var currentAlphabet: [String] {
        if let unwrappedSettings = settings {
            if unwrappedSettings.characterOrderId == CharacterOrder.alphabetical.id {
                return unwrappedSettings.predictionLanguage.alphabet
            } else if unwrappedSettings.characterOrderId == CharacterOrder.frequency.id {
                return unwrappedSettings.predictionLanguage.frequency

            } else {
                return []
            }
        }
        return []
    }
    
    init() {
        do {
            let path = Bundle.main.path(forResource: "dictionary", ofType: "sqlite")!
            let db = try Connection(path, readonly: true)
            let words = Table("words")
            
            self.dbConn = db
            self.wordsTable = words
            
        } catch {
            print(error)
        }
    }
    
    func getApplePredictionNodes(_ enteredText: String) -> [Node] {
        let predictionText = enteredText.replacingOccurrences(of: " ", with: " ")
        
        if predictionText.last == " " {
            return []
        }
        
        let lastWord = enteredText.components(separatedBy: " ").last ?? ""
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
        
        let splitBySpace = enteredText.components(separatedBy: " ")
        
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
                .filter(languageExpression == settings?.predictionLanguage.databaseLanguageCode ?? "en")
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
        
        let splitBySpace = enteredText.components(separatedBy: " ")
        
        guard let prefix = splitBySpace.last else {
            return alphabetItems
        }
        
        if prefix == "" { return alphabetItems }
        
        do {
            let wordExpression = Expression<String>("word")
            let scoreExpression = Expression<Int>("score")
            let languageExpression = Expression<String>("language")
            
            let query = words
                .filter(languageExpression == settings?.predictionLanguage.databaseLanguageCode ?? "en")
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
        
        if let unwrappedSettings = settings {
            if unwrappedSettings.appleWordPrediction {
                words += getApplePredictionNodes(enteredText)
            }
            
            if unwrappedSettings.wordPrediction {
                words += getDictPredictionNodes(enteredText)
            }
            
            words = Array(words.prefix(unwrappedSettings.wordPredictionLimit))
            
            if unwrappedSettings.letterPrediction {
                alphabetItems = getDictLetterNodes(enteredText)
            }
        }
        

        
        return words + alphabetItems
    }
    
    func loadSettings(_ settings: Settings) {
        self.settings = settings
    }
}
