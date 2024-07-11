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
    
    var allowCopy: Bool
    
    /**
     Lets you know if this is the default vocabulary to use on a freshly created app, this will only be used the first time the app is setup.
     */
    var isDefault: Bool
    
    /**
     Set slug to unique so that we can just do an upsert on systemVocabs
     */
    @Attribute(.unique) var slug: String
    
    var rootNode: Node?
    
    var createdAt: Date
    
    init(name: String, systemVocab: Bool = false, allowCopy: Bool = true, isDefault: Bool = false, slug: String? = nil, rootNode: Node) {
        self.name = name
        self.systemVocab = systemVocab
        self.isDefault = isDefault
        self.slug = slug ?? name.slugified()
        self.rootNode = rootNode
        self.createdAt = Date.now
        self.allowCopy = allowCopy
    }
    
    func copy(_ newName: String) -> Vocabulary {
        let newRootNode = self.rootNode?.copy() ?? Node(type: .root, text: "root")
        
        let newVocab = Vocabulary(
            name: newName,
            systemVocab: self.systemVocab,
            allowCopy: self.allowCopy,
            isDefault: self.isDefault,
            rootNode: newRootNode
        )
        
        return newVocab
    }
    
    public static func getSystemVocabs() -> [Vocabulary] {
        return [
            Vocabulary(
                name: "Adult Starter",
                systemVocab: true,
                isDefault: true,
                rootNode: Node(type: .root, children: [
                    Node(type: .branch, text: "Quick Words", children: [
                        Node(type: .phrase, text: "Help"),
                        Node(type: .phrase, text: "Stop"),
                        Node(type: .phrase, text: "Choking. Need suction."),
                        Node(type: .phrase, text: "More"),
                        Node(type: .phrase, text: "Less")
                    ]),
                    Node(type: .branch, text: "Chat", children: [
                        Node(type: .phrase, text: "How are you?"),
                        Node(type: .phrase, text: "What have you been doing?"),
                        Node(type: .phrase, text: "Thank You"),
                        Node(type: .phrase, text: "Let me sleep now"),
                        Node(type: .phrase, text: "When are you coming next?")
                    ]),
                    Node(type: .branch, text: "Care", children: [
                        Node(type: .phrase, text: "I need the toilet"),
                        Node(type: .phrase, text: "I'm hot"),
                        Node(type: .phrase, text: "I'm cold"),
                        Node(type: .phrase, text: "I'm in pain")
                    ]),
                    Node(type: .branch, text: "Position", children: [
                        Node(type: .phrase, text: "Move me up"),
                        Node(type: .phrase, text: "Move me down")
                    ]),
                    Node(type: .branch, text: "People", children: [
                        Node(type: .phrase, text: "Ring"),
                        Node(type: .phrase, text: "My child"),
                        Node(type: .phrase, text: "The care manager"),
                        Node(type: .phrase, text: "Someone else")
                    ]),
                    Node(type: .branch, text: "Equipment", children: [
                        Node(type: .phrase, text: "Heating"),
                        Node(type: .phrase, text: "Window"),
                        Node(type: .phrase, text: "Fan"),
                        Node(type: .phrase, text: "Radio"),
                        Node(type: .phrase, text: "Lock Door")
                    ]),
                    Node(type: .branch, text: "Feelings", children: [
                        Node(type: .phrase, text: "I'm tired"),
                        Node(type: .phrase, text: "I'm in pain"),
                        Node(type: .phrase, text: "I'm ok thanks"),
                        Node(type: .phrase, text: "I'm Bored"),
                        Node(type: .phrase, text: "I'm sad"),
                        Node(type: .phrase, text: "I'm Angry")
                    ]),
                    Node(type: .spelling, text: "I will spell it")
                ])
            ),
            Vocabulary(
                name: "Adult Ace",
                systemVocab: true,
                rootNode: Node(type: .root, children: [
                    Node(type: .branch, text: "Phrases", children: [
                        Node(type: .phrase, text: "Yes"),
                        Node(type: .phrase, text: "No"),
                        Node(type: .phrase, text: "Help"),
                        Node(type: .phrase, text: "Stop"),
                        Node(type: .phrase, text: "Suction"),
                        Node(type: .phrase, text: "Hello"),
                        Node(type: .phrase, text: "Bye"),
                        Node(type: .phrase, text: "Thank you")
                    ]),
                    Node(type: .spelling, text: "I will spell it"),
                    Node(type: .branch, text: "Chat", children: [
                        Node(type: .branch, text: "Questions", children: [
                            Node(type: .phrase, text: "How are you"),
                            Node(type: .phrase, text: "When will I see you again"),
                            Node(type: .branch, text: "Where is", children: [
                                Node(type: .phrase, text: "Family"),
                                Node(type: .phrase, text: "Staff")
                            ])
                        ]),
                        Node(type: .phrase, text: "Thank you"),
                        Node(type: .phrase, text: "I don't want to talk")
                    ]),
                    Node(type: .branch, text: "Care", children: [
                        Node(type: .phrase, text: "Wash"),
                        Node(type: .phrase, text: "Shave"),
                        Node(type: .phrase, text: "Shower"),
                        Node(type: .phrase, text: "Change"),
                        Node(type: .phrase, text: "Clothes"),
                        Node(type: .phrase, text: "Pad"),
                        Node(type: .phrase, text: "Brush teeth"),
                        Node(type: .phrase, text: "Tracheostomy"),
                        Node(type: .phrase, text: "Suctioning"),
                        Node(type: .phrase, text: "Speech Valve"),
                        Node(type: .phrase, text: "Positioning"),
                        Node(type: .phrase, text: "Move me up"),
                        Node(type: .phrase, text: "Move me down")
                    ]),
                    Node(type: .branch, text: "People", children: [
                        Node(type: .branch, text: "Family", children: [
                            Node(type: .phrase, text: "Partner"),
                            Node(type: .phrase, text: "Children"),
                            Node(type: .phrase, text: "Parents")
                        ]),
                        Node(type: .branch, text: "Health professionals", children: [
                            Node(type: .phrase, text: "Nurse"),
                            Node(type: .phrase, text: "Doctor"),
                            Node(type: .phrase, text: "O.T"),
                            Node(type: .phrase, text: "Physio"),
                            Node(type: .phrase, text: "S.L.T"),
                            Node(type: .phrase, text: "Dentist"),
                            Node(type: .phrase, text: "The care manager")
                        ]),
                        Node(type: .phrase, text: "Someone Else")
                    ]),
                    Node(type: .branch, text: "Environment", children: [
                        Node(type: .phrase, text: "Heating"),
                        Node(type: .phrase, text: "Turn up"),
                        Node(type: .phrase, text: "Turn down"),
                        Node(type: .phrase, text: "Window"),
                        Node(type: .phrase, text: "Open"),
                        Node(type: .phrase, text: "Closed"),
                        Node(type: .phrase, text: "Curtain"),
                        Node(type: .phrase, text: "Radio"),
                        Node(type: .phrase, text: "Lights"),
                        Node(type: .phrase, text: "Turn on"),
                        Node(type: .phrase, text: "Turn off"),
                        Node(type: .phrase, text: "Door"),
                        Node(type: .phrase, text: "TV"),
                        Node(type: .branch, text: "Change channel", children: [
                            Node(type: .phrase, text: "BBC one"),
                            Node(type: .phrase, text: "Audiobook")
                        ])
                    ]),
                    Node(type: .branch, text: "Feelings", children: [
                        Node(type: .phrase, text: "I'm tired"),
                        Node(type: .phrase, text: "I'm in pain"),
                        Node(type: .phrase, text: "Head"),
                        Node(type: .phrase, text: "Neck"),
                        Node(type: .phrase, text: "Chest"),
                        Node(type: .phrase, text: "Back"),
                        Node(type: .phrase, text: "Bum"),
                        Node(type: .phrase, text: "Legs"),
                        Node(type: .phrase, text: "Arms"),
                        Node(type: .phrase, text: "I'm okay thanks"),
                        Node(type: .phrase, text: "I'm bored"),
                        Node(type: .phrase, text: "I'm sad"),
                        Node(type: .phrase, text: "I'm angry")
                    ])
                ])

            ),
            Vocabulary(
                name: "Demo Vocabulary",
                systemVocab: true,
                rootNode: Node(type: .root, children: [
                    Node(type: .phrase, text: "Hello, welcome to echo"),
                    Node(type: .branch, text: "Phrases", children: [
                        Node(type: .phrase, text: "Hey"),
                        Node(type: .phrase, text: "How are you"),
                        Node(type: .phrase, text: "Tell me more"),
                        Node(type: .branch, text: "Another level", children: [
                            Node(type: .branch, text: "Another level", children: [
                                Node(type: .phrase, text: "Final level"),
                                Node(type: .branch, text: "Another level", children: [
                                    Node(type: .branch, text: "Another level", children: [
                                        Node(type: .phrase, text: "Final level"),
                                        Node(type: .branch, text: "Another level", children: [
                                            Node(type: .branch, text: "Another level", children: [
                                                Node(type: .phrase, text: "Final level"),
                                                Node(type: .back, text: "Back")
                                            ]),
                                            Node(type: .back, text: "Back")
                                        ]),
                                        Node(type: .back, text: "Back")
                                    ]),
                                    Node(type: .back, text: "Back")
                                ]),
                                Node(type: .back, text: "Back")
                            ]),
                            Node(type: .back, text: "Back")
                        ]),
                        Node(type: .back, text: "Back")
                    ]),
                    Node(type: .spelling, text: "I will spell it")
                ])

            ),
            Vocabulary(
                name: "Spelling",
                systemVocab: true,
                allowCopy: false,
                rootNode: Node(type: .rootAndSpelling)
            )
        ]
    }

}
