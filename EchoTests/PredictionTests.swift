//
//  PredictionTests.swift
//  EchoTests
//
//  Created by Gavin Henderson on 19/10/2023.
//

import XCTest
@testable import Echo

extension String {
    func getCharAtIndex(_ index: Int) -> String {
        return String(self[self.index(self.startIndex, offsetBy: index)])
    }
    
    func targetWord(_ index: Int) -> String {
        let words = self.split(separator: " ")
        
        for word in words {
            if let range = self.range(of: word) {
                let start = self.distance(from: self.startIndex, to: range.lowerBound)
                let end = start + word.count

                if index >= start && index < end {
                    return String(word)
                }
            }
        }
        
        return ""
    }
}

enum TestErrors: Error {
    case letterNotFoundInList
}

final class PredictionTests: XCTestCase {
    enum BasicError: Error {
        case textError(String)
    }
    
    var testSentences = [
        /**
         No Prediction
        1 - Select a
        13 - moves to n
        1 - select n
        1 - select word
        1 - select a
        15 - move to p
        1 - select p
        15 - move to p
        1 - select p
        11 - move to l
        1 - select l
        4 - move to e
        1 - select e
        1 - select word
        Total = 67
         */
        "an apple",
        "The quick brown fox jumps over the lazy dog.",
        "The weather forecast predicts rain with a chance of thunderstorms",
        "Please send me the latest sales report by the end of the day",
        "I'm interested in learning more about machine learning and artificial intelligence",
        "The sun sets in the west, casting a warm, golden glow over the horizon",
        "She played a beautiful melody on her violin, filling the room with enchanting music.",
        "The scientist conducted experiments to prove his groundbreaking theory.",
        "He embarked on a journey to explore the uncharted wilderness.",
        "The ancient castle stood atop the hill, shrouded in legends and mysteries.",
        "The chef prepared a delicious gourmet meal that delighted the guests."
    ]
    
    func normaliseString(_ given: String) -> String {
        let allowedLetters = "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z, ,·".components(separatedBy: ",")
        let lowered = given.lowercased()
        let split = lowered.split(separator: "")
        
        let filtered = split.filter { current in
            return allowedLetters.contains(String(current))
        }
        
        return filtered
            .joined(separator: "")
            
    }
    
    func calculateScore(spelling: SpellingOptions, targetSentence: String, testName: String) throws -> Int {
        var currentMessage = ""
        var totalCount = 0
        
        // Loop while the current message does not equal the complete message
        while normaliseString(targetSentence) != normaliseString(currentMessage).trimmingCharacters(in: .whitespacesAndNewlines) {
            // Only pass the last word to prediction
            let predictionList = spelling.predict(enteredText: currentMessage.replacingOccurrences(of: " ", with: "·"))
            
            let normalisedTargetSentence = normaliseString(targetSentence)
            let normalisedCurrentMessage = normaliseString(currentMessage)
            
            let targetWord = normalisedTargetSentence.targetWord(normalisedCurrentMessage.count)
            let targetLetter = normalisedTargetSentence.getCharAtIndex(normalisedCurrentMessage.count)
            
            if targetLetter == " " {
                totalCount += 1
                currentMessage += " "
                continue
            }
            
            guard let positionInList = predictionList.firstIndex(where: { current in
                if current.details.displayText == targetWord {
                    return true
                }
                
                if current.details.displayText == targetLetter {
                    return true
                }
                
                return false
            }) else {
                throw TestErrors.letterNotFoundInList
            }
            
            totalCount += positionInList + 1
            
            currentMessage += predictionList[positionInList].details.letter.replacingOccurrences(of: "·", with: " ")
        }
        
        print(testName, targetSentence, totalCount)
        
        return totalCount
    }
    
    func testTargetWord() {
        XCTAssertEqual(
            "an apple".targetWord(0),
            "an"
        )
        XCTAssertEqual(
            "an apple".targetWord(1),
            "an"
        )
        XCTAssertEqual(
            "an apple".targetWord(2),
            ""
        )
        XCTAssertEqual(
            "an apple".targetWord(3),
            "apple"
        )
        XCTAssertEqual(
            "an apple".targetWord(4),
            "apple"
        )
    }
    
    func testUseEnglishIfPredictionLangugeIsMalformed() {
        let spelling = SpellingOptions()
        
        spelling.letterPrediction = true
        spelling.wordPrediction = true
        spelling.wordPredictionLimit = 3
        spelling.predictionLanguage = "MALFORMED"
        
        XCTAssertEqual(spelling.language, .english)
    }
    
    func testAllSentences(spelling: SpellingOptions, testName: String) throws -> Int {
        var totalScore = 0
        
        for sentence in testSentences {
            do {
                totalScore += try calculateScore(spelling: spelling, targetSentence: sentence, testName: testName)
            } catch {
                throw error
            }
        }
        
        print(testName, "Total Score = ", totalScore)
        print("")
        
        return totalScore
    }
    
    func testPredictionMeasure() throws {
        var scoreMap: [String: Int] = [:]
        
        var spelling = SpellingOptions()
        spelling.letterPrediction = false
        spelling.wordPrediction = false
        spelling.wordPredictionLimit = 3
        spelling.characterOrderId = CharacterOrder.alphabetical.id
        scoreMap["No Prediction"] = try testAllSentences(spelling: spelling, testName: "No Prediction")
        
        spelling = SpellingOptions()
        spelling.letterPrediction = true
        spelling.wordPrediction = false
        spelling.wordPredictionLimit = 3
        spelling.characterOrderId = CharacterOrder.alphabetical.id
        scoreMap["Letter Prediction"] = try testAllSentences(spelling: spelling, testName: "Letter Prediction")
        
        spelling = SpellingOptions()
        spelling.letterPrediction = false
        spelling.wordPrediction = false
        spelling.characterOrderId = CharacterOrder.frequency.id
        scoreMap["Frequency"] = try testAllSentences(spelling: spelling, testName: "Frequency")

        spelling = SpellingOptions()
        spelling.letterPrediction = true
        spelling.wordPrediction = true
        spelling.wordPredictionLimit = 3
        spelling.characterOrderId = CharacterOrder.alphabetical.id
        scoreMap["Word and Letter Prediction"] = try testAllSentences(spelling: spelling, testName: "Word and Letter Prediction")
        
        spelling = SpellingOptions()
        spelling.letterPrediction = true
        spelling.wordPrediction = true
        spelling.wordPredictionLimit = 3
        spelling.characterOrderId = CharacterOrder.frequency.id
        scoreMap["Word, Letter, Frequency"] = try testAllSentences(spelling: spelling, testName: "Word, Letter, Frequency")

        spelling = SpellingOptions()
        spelling.letterPrediction = false
        spelling.wordPrediction = true
        spelling.wordPredictionLimit = 3
        spelling.characterOrderId = CharacterOrder.alphabetical.id
        scoreMap["Word Prediction"] = try testAllSentences(spelling: spelling, testName: "Word Prediction")
        
        for (key, value) in scoreMap.sorted(by: { $0.value > $1.value }) {
            print("\(key): \(value)")
        }
    }
}
