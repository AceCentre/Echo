//
//  VocabularyOptionsArea.swift
// Echo
//
//  Created by Gavin Henderson on 27/06/2024.
//
import SwiftUI
import SwiftData

struct VocabularyOptionsArea: View {
    @Environment(Settings.self) var settings: Settings
    @EnvironmentObject var editState: EditState
    
    @Query(sort: \Vocabulary.createdAt) var allVocabs: [Vocabulary]
    
    @Environment(\.modelContext) var modelContext
    
    @State var selectedVocab = Vocabulary(name: "temp", rootNode: Node(type: .root))
    
    @State var showCopyAlert = false
    @State var copyVocabName = ""
    
    @State var showEditMode = false
    
    var body: some View {
        
        if showEditMode {
            EditPage(save: {
                showEditMode = false
            })
        } else {
            
            @Bindable var bindableSettings = settings
            
            Form {
                Section(content: {
                    Picker(
                        String(
                            localized: "Vocabulary",
                            comment: "The label that is shown next to the vocab picker"
                        ),
                        selection: $selectedVocab
                    ) {
                        ForEach(allVocabs, id: \.self) { vocab in
                            Text(vocab.name).tag(vocab)
                        }
                    }
                    VStack {
                        HStack {
                            Button(action: {
                                
                                if UIDevice.current.userInterfaceIdiom == .pad {
                                    editState.showEditMode = true
                                    
                                } else {
                                    showEditMode = true
                                }
                            }) {
                                Text("Edit", comment: "Text for edit vocabulary button")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(selectedVocab.systemVocab)
                            
                            
                            Button(action: {
                                showCopyAlert = true
                                copyVocabName = "Copy of '\(selectedVocab.name)'"
                            }) {
                                Text("Copy", comment: "Text for copy vocabulary button")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .disabled(!selectedVocab.allowCopy)
                        }
                        .alert(
                            String(localized: "Copy Vocabulary", comment: "Alert title for copying vocab"),
                            isPresented: $showCopyAlert
                        ) {
                            TextField(String(localized: "Name of the new vocabulary", comment: "TextField label for new vocabulary (hidden"), text: $copyVocabName)
                            Button(String(localized: "Make copy", comment: "Button text for making copy of a vocabulary")) {
                                if let newVocab = settings.currentVocab?.copy(copyVocabName) {
                                    newVocab.systemVocab = false
                                    modelContext.insert(newVocab)
                                    selectedVocab = newVocab
                                }
                            }
                            .disabled(selectedVocab.name == copyVocabName)
                            Button("Cancel", role: .cancel) {
                                showCopyAlert = false
                            }
                        } message: {
                            Text("Make a copy of the current vocabulary so you can make edits.", comment: "Message for copying vocab alert")
                        }
                        
                        if !selectedVocab.allowCopy {
                            Text("The copy and edit button are disabled because you cannot copy or edit the spelling vocabulary. Click the spelling and alphabet tab to change spelling options.", comment: "Explanation of why the copy button on the vocab is disabled")
                        } else if selectedVocab.systemVocab {
                            Text("The edit button is currently disabled because you are trying to edit a system vocabulary. To edit this vocabulary you must make a copy first.", comment: "Explanation of why the edit button on the vocab is disabled")
                        }
                    }
                }, header: {
                    Text("Vocabulary", comment: "Header of vocabulary options")
                }, footer: {
                    Text("Select the vocabulary of phrases, words and letters to be used", comment: "Footer of vocabulary options")
                })
                Section(content: {
                    Stepper(
                        value: $bindableSettings.vocabHistory,
                        in: 1...10,
                        step: 1
                    ) {
                        Text(
                            "Show **\(bindableSettings.vocabHistory)** level of your vocabulary",
                            comment: "Describe to the user the number of history levels"
                        )
                    }
                }, header: {
                    Text("History", comment: "Header for settings about history")
                }, footer: {
                    Text("This is the number of levels of your phrases to show at once.", comment: "Footer for settings about history")
                })
            }
            .navigationTitle(
                String(
                    localized: "Vocabulary",
                    comment: "The navigation title for the Vocabulary options page"
                )
            )
            .onAppear {
                if let unwrapped = settings.currentVocab {
                    selectedVocab = unwrapped
                }
            }
            .onChange(of: selectedVocab) {
                settings.currentVocab = selectedVocab
            }
        }
    }
}
