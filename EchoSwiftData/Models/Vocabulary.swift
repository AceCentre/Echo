//
//  Vocabulary.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 24/05/2024.
//

import Foundation
import SwiftData

@Model
class Vocabulary {
    /**
     The name of the vocabulary
     */
    var name: String
    
    /**
     If the vocab is a systemVocab this will block deleting, editing etc
     */
    var systemVocab: Bool
    
    /**
     Lets you know if this is the default vocabulary to use on a freshly created app, this will only be used the first time the app is setup.
     */
    var isDefault: Bool
    
    /**
     Set slug to unique so that we can just do an upsert on systemVocabs
     */
    @Attribute(.unique) var slug: String
    
    init(name: String, systemVocab: Bool = false, isDefault: Bool = false, slug: String? = nil) {
        self.name = name
        self.systemVocab = systemVocab
        self.isDefault = isDefault
        self.slug = slug ?? name.slugified()
    }
    
    public static func getSystemVocabs() -> [Vocabulary] {
        return [
            Vocabulary(name: "First System Vocab", systemVocab: true),
            Vocabulary(name: "Second System Vocab", systemVocab: true, isDefault: true),
            Vocabulary(name: "Third System Vocab", systemVocab: true),
        ]
    }

}

