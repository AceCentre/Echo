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

struct PredictionLanguage: Hashable, Identifiable {
    var id: String
    var display: String
    var alphabet: [String]
    var frequency: [String]
    var databaseLanguageCode: String
    var acceptedPreferredLangs: [String]
    
    static public var english = PredictionLanguage(
        id: "en",
        display: String(
            localized: "English",
            comment: "The label for the English language when setting prediction language"
        ),
        alphabet: "a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z".components(separatedBy: ","),
        frequency: "e,i,s,a,t,n,r,o,l,c,d,p,u,m,g,h,y,f,b,v,w,k,x,j,q,z".components(separatedBy: ","),
        databaseLanguageCode: "en",
        acceptedPreferredLangs: ["en"]
    )
    
    static public var arabic = PredictionLanguage(
        id: "ar",
        display: String(
            localized: "Arabic (Experimental)",
            comment: "The label for the Arabic language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "چ,ج,ح,خ,ه,ع,غ,ف,ق,ث,ص,ض,گ,ک,م,ن,ت,ا,ل,ب,ی,س,ش,و,پ,د,ذ,ر,ز,ط,ظ".components(separatedBy: ","),
        frequency: "چ,ا,ل,ر,ن,ت,و,ب,د,م,ع,ق,س,ح,ه,ف,ج,ط,ص,ش,خ,ض,ذ,ث,غ,گ,ک,ی,پ,ز,ظ".components(separatedBy: ","),
        databaseLanguageCode: "ar",
        acceptedPreferredLangs: ["ar"]
    )
    
    static public var welsh = PredictionLanguage(
        id: "cy",
        display: String(
            localized: "Welsh (Experimental)",
            comment: "The label for the Welsh language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "a,b,c,ch,d,dd,e,f,ff,g,ng,h,i,j,l,ll,m,n,o,p,ph,r,rh,s,t,th,u,w,y".components(separatedBy: ","),
        frequency: "a,d,i,e,r,n,l,o,y,t,s,w,c,g,h,u,m,b,ch,dd,f,ff,ng,p,j,ll,ph,rh,th".components(separatedBy: ","),
        databaseLanguageCode: "cy",
        acceptedPreferredLangs: ["cy"]
    )
    
    static public var spanish = PredictionLanguage(
        id: "es",
        display: String(
            localized: "Spanish (Experimental)",
            comment: "The label for the Spanish language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "a,á,b,c,d,e,é,f,g,h,i,í,j,k,l,m,n,ñ,o,ó,p,q,r,s,t,u,ú,ü,v,w,x,y,z".components(separatedBy: ","),
        frequency: "a,e,r,o,s,i,n,t,c,l,d,m,u,p,b,g,v,f,á,í,é,ó,h,z,j,q,x,ñ,y,ú,k,ü,w".components(separatedBy: ","),
        databaseLanguageCode: "es",
        acceptedPreferredLangs: ["es"]
    )
    
    static public var hebrew = PredictionLanguage(
        id: "he",
        display: String(
            localized: "Hebrew (Experimental)",
            comment: "The label for the Hebrew language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "א,בּ,ב,גּ,ג,דּ,ד,ה,ו,ז,ח,ט,י,כּ,כ,ךּ,ך,ל,מ,ם,נ,ן,ס,ע,פּ,פ,ף,צ,ץ,ק,ר,שׁ,שׂ,תּ,ת".components(separatedBy: ","),
        frequency: "א,בּ,י,ו,ל,ב,גּ,מ,ת,ע,ם,נ,ח,כ,ג,דּ,ה,ר,ד,ק,ן,פ,ס,צ,ך,ז,ט,כּ,ךּ,פּ,ף,ץ,שׁ,שׂ,תּ".components(separatedBy: ","),
        databaseLanguageCode: "he",
        acceptedPreferredLangs: ["he"]
    )
    
    static public var croatian = PredictionLanguage(
        id: "hr",
        display: String(
            localized: "Croatian (Experimental)",
            comment: "The label for the Croatian language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "a,b,c,ć,č,d,đ,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,š,t,u,v,w,x,z,ž".components(separatedBy: ","),
        frequency: "a,i,o,e,t,r,n,s,j,l,p,k,u,d,v,m,z,b,g,č,š,c,ž,ć,h,f,đ,q,w,x".components(separatedBy: ","),
        databaseLanguageCode: "hr",
        acceptedPreferredLangs: ["hr"]
    )

    static public var maori = PredictionLanguage(
        id: "mi",
        display: String(
            localized: "Māori (Experimental)",
            comment: "The label for the Māori language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "a,ā,e,ē,h,i,ī,k,m,n,ng,o,ō,p,r,t,u,ū,w,wh".components(separatedBy: ","),
        frequency: "a,i,k,t,h,u,r,o,e,n,p,ā,m,w,ō,ū,ī,ē,ng,wh".components(separatedBy: ","),
        databaseLanguageCode: "mi",
        acceptedPreferredLangs: ["mi"]
    )
    
    static public var polish = PredictionLanguage(
        id: "pl",
        display: String(
            localized: "Polish (Experimental)",
            comment: "The label for the Polish language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "a,ä,ą,b,c,ć,d,e,ę,f,g,h,i,j,k,l,ĺ,ł,m,n,ń,o,ó,p,r,s,ś,t,u,w,x,y,z,ź,ż".components(separatedBy: ","),
        frequency: "i,a,e,o,z,n,c,s,r,w,y,m,t,d,k,p,j,u,l,b,ł,g,ś,ó,h,ę,ż,ą,ć,f,ń,ź,ä,ĺ,x".components(separatedBy: ","),
        databaseLanguageCode: "pl",
        acceptedPreferredLangs: ["pl"]
    )
    
    static public var portuguese = PredictionLanguage(
        id: "pt",
        display: String(
            localized: "Portuguese (Experimental)",
            comment: "The label for the portuguese language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "a,ª,á,à,ă,â,å,ä,ã,b,c,ç,d,e,é,è,ê,f,g,h,i,í,ì,ï,j,k,l,m,n,ñ,o,º,ó,ò,ô,õ,p,q,r,s,t,u,ú,ü,v,w,x,y,z".components(separatedBy: ","),
        frequency: "a,e,o,r,s,i,n,t,c,m,d,l,u,p,g,v,h,b,f,á,ç,z,j,y,x,k,ã,q,í,w,ó,é,ê,õ,ú,â,ô,à,ä,ü,ª,ñ,è,º,ò,å,ă,ì,ï".components(separatedBy: ","),
        databaseLanguageCode: "pt",
        acceptedPreferredLangs: ["pt", "pt-PT", "pt-BR"]
    )
    
    static public var urdu = PredictionLanguage(
        id: "ur",
        display: String(
            localized: "Urdu (Experimental)",
            comment: "The label for the urdu language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "آ,ئ,ا,ب,پ,ت,ث,ٹ,ج,چ,ح,خ,د,ذ,ڈ,ر,ز,ڑ,س,ش,ص,ض,ط,ظ,ع,غ,ف,ق,ك,ک,گ,ل,م,ن,ں,ه,ھ,ہ,و,ى,ي,ی,ے".components(separatedBy: ","),
        frequency: "ا,ی,ر,م,و,ت,ہ,ن,ل,ک,د,س,ب,ے,ج,ع,ق,ں,ھ,گ,پ,ح,ز,ف,ش,ئ,چ,خ,آ,ص,ط,ض,ظ,ٹ,غ,ث,ڑ,ك,ي,ذ,ڈ,ى,ه".components(separatedBy: ","),
        databaseLanguageCode: "ur",
        acceptedPreferredLangs: ["ur"]
    )
    
    static public var yidish = PredictionLanguage(
        id: "yi",
        display: String(
            localized: "Yiddish (Experimental)",
            comment: "The label for the Yiddish language when setting prediction language, make sure to include the experimental tag"
        ),
        alphabet: "א,ב,ג,ד,ה,ו,װ,ז,ח,ט,י,ײ,כ,ך,ל,מ,ם,נ,ן,ס,ע,פ,ף,צ,ץ,ק,ר,ש,ת".components(separatedBy: ","),
        frequency: "י,ע,א,ר,ו,ט,נ,ל,ן,ג,פ,ב,מ,ד,ש,ס,ק,ה,ז,צ,ם,כ,ך,ת,ח,ף,ץ,ײ,װ".components(separatedBy: ","),
        databaseLanguageCode: "yi",
        acceptedPreferredLangs: ["yi"]
    )
    
    static public var allLanguages: [PredictionLanguage] = [.english, .welsh, .arabic, .spanish, .hebrew, .croatian, .maori, .polish, .urdu, .yidish, .portuguese]
    static public var defaultLanguage: PredictionLanguage = .english
}

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
    
    public static var defaultOrder: CharacterOrder = .alphabetical
}

class SpellingOptions: ObservableObject, Analytic {
    @AppStorage(StorageKeys.letterPrediction) var letterPrediction: Bool = true
    @AppStorage(StorageKeys.wordPrediction) var wordPrediction: Bool = true
    @AppStorage(StorageKeys.wordPredictionLimit) var wordPredictionLimit: Int = 3
    @AppStorage(StorageKeys.predictionLanguage) var predictionLanguage: String = "DEFAULT"
    @AppStorage(StorageKeys.characterOrder) var characterOrderId: String = CharacterOrder.defaultOrder.id
    @AppStorage(StorageKeys.wordAndLetterPrompt) var wordAndLetterPrompt: Bool = true
    
    var analytics: Analytics?
    
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
    
    func loadAnalytics(analytics: Analytics) {
        self.analytics = analytics
    }
    
    init() {
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
    }

    // swiftlint:disable function_body_length
    func predict(enteredText: String) -> [Item] {
        guard let db = dbConn else { return [] }
        guard let words = wordsTable else { return [] }
        
        let alphabet = currentAlphabet
        let alphabetItems = alphabet.map { currentPrediction in
            return Item(letter: currentPrediction, letterType: .letter, analytics: self.analytics)
        }
        
        var alphabetScores: [String: Int] = [:]
        
        let splitBySpace = enteredText.components(separatedBy: "·")

        guard let prefix = splitBySpace.last else {
            return alphabetItems
        }
        
        if prefix == "" { return alphabetItems }
        
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
                let unwrappedScore = try word.get(scoreExpression)
                
                if nextCharPos < unwrappedWord.count {
                    wordPredictions.append(unwrappedWord)
                    
                    let nextCharIndex = unwrappedWord.index(unwrappedWord.startIndex, offsetBy: nextCharPos)
                    let nextChar = unwrappedWord[nextCharIndex].lowercased()
                    
                    if alphabet.contains(nextChar) {
                        let currentScore = alphabetScores[nextChar, default: 0]
                        alphabetScores[nextChar] = currentScore + unwrappedScore
                    }
                }
            }
            
        } catch {
            print(error)
            return alphabetItems
        }
        
        let sortedAlphabet = alphabet.sorted {
            let firstScore = alphabetScores[$0, default: 0]
            let secondScore = alphabetScores[$1, default: 0]
                            
            return firstScore > secondScore
        }.map { currentPrediction in
            let isPredictedLetter = alphabetScores[currentPrediction, default: 0] > 0
            
            return Item(
                letter: currentPrediction,
                letterType: isPredictedLetter ? .predictedLetter : .letter, analytics: self.analytics)
        }
        
        let finalAlphabet = letterPrediction ? sortedAlphabet : alphabetItems
        
        if wordPrediction {
            let wordItems = wordPredictions.prefix(wordPredictionLimit).map { word in
                let wordWithoutPrefix = String(word.dropFirst(prefix.count))

                return Item(letter: wordWithoutPrefix+"·", display: word, speakText: word, letterType: .predictedWord, analytics: self.analytics)
            }
            
            return wordItems + finalAlphabet
        }
        
        return finalAlphabet
    }
    // swiftlint:enable function_body_length

}
