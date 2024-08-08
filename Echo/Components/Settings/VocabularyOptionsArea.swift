//
//  VocabularyOptionsArea.swift
// Echo
//
//  Created by Gavin Henderson on 27/06/2024.
//
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct VocabularyOptionsArea: View {
    @Environment(Settings.self) var settings: Settings
    @EnvironmentObject var editState: EditState
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var errorHandling: ErrorHandling
    
    @Query(sort: \Vocabulary.createdAt) var allVocabs: [Vocabulary]
    
    @Environment(\.modelContext) var modelContext
    
    @State var selectedVocab = Vocabulary(name: "temp", rootNode: Node(type: .root))
    
    @State var showCopyAlert = false
    @State var copyVocabName = ""
    @State var vocabToCopy = Vocabulary(name: "temp", rootNode: Node(type: .root))

    @State var showDeleteAlert = false
    @State var vocabToDelete = Vocabulary(name: "temp", rootNode: Node(type: .root))

    @State var newVocabAlert = false
    @State var newVocabName = ""
    
    @State var showEditMode = false
    
    @State var currentFilePath: URL?
    @State var showFileImporter = false

    let echoType = UTType(exportedAs: "uk.org.acecentre.echo", conformingTo: .text)
    
    var body: some View {
        ZStack {
            if showEditMode {
                EditPage(save: {
                    showEditMode = false
                })
            } else {
                
                @Bindable var bindableSettings = settings
                
                Form {
                    Section(content: {
                        List(allVocabs) { currentVocab in
                            Button(action: {
                                selectedVocab = currentVocab
                            }) {
                                HStack {
                                    if selectedVocab == currentVocab {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text(currentVocab.name)
                                        .foregroundStyle(colorScheme == .light ? .black : .white)
                                    Spacer()
                                        .frame(maxWidth: .infinity)
                                    
                                    if !currentVocab.systemVocab {
                                        Button(action: {
                                            selectedVocab = currentVocab
                                            if UIDevice.current.userInterfaceIdiom == .pad {
                                                editState.showEditMode = true
                                                
                                            } else {
                                                showEditMode = true
                                            }
                                        }, label: {
                                            Label(String(localized: "Edit", comment: "Edit text shown to edit a vocab"), systemImage: "square.and.pencil")
                                        })
                                        
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .swipeActions(allowsFullSwipe: false) {
                                if !currentVocab.systemVocab {
                                    Button(role: .destructive) {
                                        vocabToDelete = currentVocab
                                        showDeleteAlert = true
                                        
                                    } label: {
                                        Label(String(localized: "Delete", comment: "Label for deleting a vocab"), systemImage: "trash.fill")
                                    }
                                }
                            }
                            .swipeActions(edge: .leading) {
                                if currentVocab.allowCopy {
                                    Button {
                                        vocabToCopy = currentVocab
                                        copyVocabName = ""
                                        showCopyAlert = true
                                    } label: {
                                        Label(String(localized: "Copy", comment: "Label for copying a vocab"), systemImage: "doc.on.doc")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                        Button(action: {
                            newVocabAlert = true
                            newVocabName = ""
                        }, label: {
                            Label(String(localized: "New Vocabulary", comment: "Label to create a new vocab"), systemImage: "plus")
                        })
                        .padding(.vertical, 8)
                        
                    }, header: {
                        Text("Vocabulary", comment: "Header of vocabulary options")
                    }, footer: {
                        Text("Select the vocabulary of phrases, words and letters to be used", comment: "Footer of vocabulary options")
                    })
                    .alignmentGuide(.listRowSeparatorLeading) { viewDimensions in
                        return viewDimensions[.leading]
                    }
                    .alignmentGuide(.listRowSeparatorTrailing) { viewDimensions in
                        return viewDimensions[.trailing]
                    }
                    
                    Section(content: {
                        if let unwrappedFile = currentFilePath, selectedVocab.allowCopy == true {
                            ShareLink(String(localized: "Export current vocabulary", comment: "Text on export vocab button"), item: unwrappedFile)
                        }
                        Button(action: {
                            showFileImporter = true
                            
                        }) {
                            Text("Import a vocabulary", comment: "Text on inport vocab button")
                        }
                        .fileImporter(
                               isPresented: $showFileImporter,
                               allowedContentTypes: [echoType],
                               allowsMultipleSelection: false
                           ) { result in
                               do {
                                   switch result {
                                   case .success(let files):
                                       for file in files {
                                           let gotAccess = file.startAccessingSecurityScopedResource()
                                           if !gotAccess { throw EchoError.noFileAccess }
                                           
                                           let fileContent = try String(contentsOf: file, encoding: String.Encoding.utf8)
                                                                                      
                                           let decoder = JSONDecoder()
                                           if let data = fileContent.data(using: .utf8) {
                                               let newVocab = try decoder.decode(Vocabulary.self, from: data)

                                               
                                               var vocabName = newVocab.name
                                               var counter = 1
                                               
                                               let vocabNames = allVocabs.map { $0.name }
                                               
                                               while vocabNames.contains(vocabName) {
                                                   vocabName = "\(vocabName) \(counter)"
                                                   counter += 1
                                               }
                                               
                                               
                                               newVocab.name = vocabName
                                               newVocab.slug = vocabName.slugified()
                                               
                                               modelContext.insert(newVocab)
                                               try modelContext.save()
                                               
                                               selectedVocab = newVocab
                                           } else {
                                               throw EchoError.failedToParseFile
                                           }
                                           
                                           file.stopAccessingSecurityScopedResource()
                                       }
                                   case .failure(let error):
                                       throw error
                                   }
                               } catch {
                                   errorHandling.handle(error: error)
                               }
                           }
                    }, header: {
                        Text("Backup Vocabulary", comment: "Header text for vocab backup section")
                    }, footer: {
                        Text("You can export your vocabulary to a file and then save it and store it. You can then import the same file on any device running echo", comment: "Footer text for vocab backup section")
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
                    
                    Section(content: {
                        Toggle(isOn: $bindableSettings.showBackInList) {
                            Text("Show Back Button", comment: "Label on settings toggle for back button")
                        }
                        
                        if bindableSettings.showBackInList == true {
                            Picker(String(localized: "Back Position", comment: "Label for picker for back position"), selection: $bindableSettings.backButtonPosition) {
                                Text("Start of list").tag(BackButtonPosition.top.rawValue)
                                Text("End of list").tag(BackButtonPosition.bottom.rawValue)
                            }
                            
                        }
                    }, footer: {
                        Text("Show a 'back' item in each branch letting you navigate to the previous branch", comment: "Footer description for back button")
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
                    
                    do {
                        if let unwrappedVocab = settings.currentVocab {
                            let jsonEncoder = JSONEncoder()
                            let jsonData = try jsonEncoder.encode(unwrappedVocab)
                            if let json = String(data: jsonData, encoding: String.Encoding.utf8) {
                                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                                let filename = paths[0].appendingPathComponent("\(unwrappedVocab.name).echo")
                                
                                try json.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                                
                                currentFilePath = filename
                            } else {
                                throw EchoError.failedToSaveVocabFile
                            }
                        } else {
                            throw EchoError.failedToSaveVocabFile
                        }
                    } catch {
                        errorHandling.handle(error: error)
                    }
                }
                
            }
        }
        .alert(
            String(localized: "Delete Vocabulary: \(vocabToDelete.name)", comment: "Alert title for deleting vocab"),
            isPresented: $showDeleteAlert
        ) {
            Button(String(localized: "Delete", comment: "Button text for deleting a vocabulary")) {
                _ = vocabToDelete.rootNode?.delete()
                modelContext.delete(vocabToDelete)

                if let firstVocab = allVocabs.first, selectedVocab == vocabToDelete {
                    selectedVocab = firstVocab
                }
            }
            Button(String(localized: "Cancel", comment: "Label for closing an alert"), role: .cancel) {
                showDeleteAlert = false
            }
        } message: {
            Text("Deleting a vocabulary is irreversible.", comment: "Warning about deleting a vocab")
        }
        .textCase(nil)
        
        .sheet(isPresented: $showCopyAlert, content: {
            NavigationStack {
                
                Form {
                    Section(content: {
                        TextField(String(localized: "Copy of '\(vocabToCopy.name)'", comment: "Placeholder text for copying a vocab"), text: $copyVocabName)
                    }, header: {
                        Text("Vocabulary Name", comment: "Header for vocab name section")
                    })
                    Button(action: {
                        let newVocab = vocabToCopy.copy(copyVocabName)
                        newVocab.systemVocab = false
                        modelContext.insert(newVocab)
                        selectedVocab = newVocab
                        
                        showCopyAlert = false
                    }, label: {
                        HStack {
                            Spacer()
                                .frame(maxWidth: .infinity)
                            Text("Copy", comment: "Label for copy vocab button")
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    })
                    .disabled((allVocabs.map { $0.name }).contains(copyVocabName) || copyVocabName == "")
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .listRowBackground(Color.clear)
                }
                
                .navigationTitle(String(localized: "Copy vocabulary", comment: "Navigation Title for copy vocab"))
                .toolbar {
                    ToolbarItem {
                        Button(String(localized: "Cancel", comment: "label for closing a sheet"), role: .cancel) {
                            showCopyAlert = false
                        }
                    }
                }
            }
        })

        
        .sheet(isPresented: $newVocabAlert, content: {
            NavigationStack {
                
                Form {
                    Section(content: {
                        TextField(String(localized: "My new vocabulary", comment: "Placeholder for new vocab name"), text: $newVocabName)
                    }, header: {
                        Text("Vocabulary Name", comment: "Header for new vocab name section")
                    })
                    Button(action: {
                        let newVocab = Vocabulary(
                            name: newVocabName,
                            systemVocab: false,
                            allowCopy: true,
                            rootNode: Node(type: .root, children: [
                                Node(type: .phrase, text: String(localized: "First phrase in new vocab", comment: "Default new node text"), children: [])
                            ])
                        )
                        modelContext.insert(newVocab)
                        selectedVocab = newVocab
                        newVocabAlert = false
                    }, label: {
                        HStack {
                            Spacer()
                                .frame(maxWidth: .infinity)
                            Text("Create", comment: "Create new vocab button")
                            Spacer()
                                .frame(maxWidth: .infinity)
                        }
                    })
                    .disabled((allVocabs.map { $0.name }).contains(newVocabName) || newVocabName == "")
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .listRowBackground(Color.clear)
                }
                
                .navigationTitle(String(localized: "Create a new vocabulary", comment: "Navigation title for creating a new vocab"))
                .toolbar {
                    ToolbarItem {
                        Button(String(localized: "Cancel", comment: "Button to close modal"), role: .cancel) {
                            newVocabAlert = false
                        }
                    }
                }
            }
        })
    }
    
}
