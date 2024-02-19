//
//  AddSwitch.swift
//  Echo
//
//  Created by Gavin Henderson on 10/10/2023.
//

import Foundation
import SwiftUI

struct DetectSwitch: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // periphery:ignore
    @Binding var selectedKey: UIKeyboardHIDUsage?
    
    var body: some View {
        ZStack {
            KeyboardPressDetectorView { press in
                self.selectedKey = press.key?.keyCode
                presentationMode.wrappedValue.dismiss()
            }
            Form {
                VStack {
                    ProgressView()
                    Text("Activate your external switch", comment: "Shown when detecting the switch press when adding a new switch")
                        .font(.title2)
                    Text("""
                 External switches can be a bluetooth or wired device such as a keyboard, controller or switch
                 """, comment: "Explains what an external switch is")
                    .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
        }
    }
}

struct AddSwitchSheet: View {
    @Binding var showNewSwitchSheet: Bool
    @Binding var currentSwitch: Switch?
    
    var body: some View {
        ZStack {}
            .sheet(isPresented: $showNewSwitchSheet) {
                AddSwitch().interactiveDismissDisabled()
            }.interactiveDismissDisabled()
            .sheet(item: $currentSwitch) { currentSwitchObject in
                AddSwitch(
                    switchName: currentSwitchObject.name,
                    selectedKey: currentSwitchObject.key,
                    tapAction: currentSwitchObject.tapAction,
                    holdAction: currentSwitchObject.holdAction,
                    id: currentSwitchObject.id
                ).interactiveDismissDisabled()
            }
    }
}

struct AddSwitch: View {
    @EnvironmentObject var accessOptions: AccessOptions
    @Environment(\.presentationMode) var presentationMode
    
    @State var switchName = ""
    @State var selectedKey: UIKeyboardHIDUsage?
    @State var tapAction: Action = .nextNode
    @State var holdAction: Action = .none
    @State var id: UUID?
    
    @State var deleteAlert: Bool = false
    
    func initSwitchName() {
        if switchName != "" { return }
        
        let switchNumber = accessOptions.listOfSwitches.count + 1
        switchName = String(
            localized: "Switch \(switchNumber)",
            comment: "The default switch name"
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(content: {
                    TextField(
                        String(localized: "Switch Name", comment: "Label for switch name TextField"),
                        text: $switchName,
                        prompt: Text("Required", comment: "Prompt for required text input"))
                }, header: {
                    Text("Switch Name", comment: "Label shown on the switch name input")
                })
                Section(content: {
                    if let unwrappedKey = selectedKey {
                        HStack {
                            Text("Selected Key", comment: "Label for showing the value of the key that has been selected for an external switch")
                            Spacer()
                            Text(keyToDisplay(unwrappedKey))
                                .foregroundStyle(.gray)
                        }
                    }
                    
                    NavigationLink(destination: {
                        DetectSwitch(selectedKey: $selectedKey)
                    }, label: {
                        Label(
                            String(
                                localized: "Detect Switch",
                                comment: "Label for a NavigationLink that will get a user to press their external switch"
                            ),
                            systemImage: "button.programmable.square"
                        )
                    })
                    
                }, header: {
                    Text("Switch Key", comment: "Header text for the switch keyboard area")
                }, footer: {
                    Text(
                        "Let Echo know what switch you want to use by pressing it. If you change your mind you can reset the chosen switch.",
                        comment: "A description of how detecting switches works and how to reset it"
                    )
                })
                
                Section(content: {
                    
                    ActionPicker(
                        label: String(
                            localized: "Single Tap",
                            comment: "The label that is shown next to the single tap action"
                        ),
                        selected: $tapAction,
                        actions: Action.tapCases
                    )
                    
                    ActionPicker(
                        label: String(
                            localized: "Hold",
                            comment: "The label that is shown next to the single hold action"
                        ),
                        selected: $holdAction,
                        actions: Action.holdCases
                    )

                }, header: {
                    Text("Actions", comment: "The header of the actions area when adding a new switch")
                }, footer: {
                    Text(
                        "These are the actions that will happen when you tap or hold your switch",
                        comment: "The footer description of the area of the actions area when adding a new switch"
                    )
                })
                
                if id != nil {
                    Section(content: {
                        Button(action: {
                            deleteAlert = true
                        }, label: {
                            Label(
                                String(
                                    localized: "Delete Switch",
                                    comment: "The label for the button to delete a switch"
                                ),
                                systemImage: "trash"
                            )
                            .foregroundColor(.red)
                        })
                        .alert(String(localized: "Delete Switch", comment: "Title for alert about deleting a switch"), isPresented: $deleteAlert) {
                            Button(String(localized: "Delete", comment: "Button label to confirm deletion"), role: .destructive) {
                                if let unwrappedId = id {
                                    accessOptions.deleteSwitch(id: unwrappedId)
                                }
                                
                                presentationMode.wrappedValue.dismiss()
                            }
                            Button(String(localized: "Cancel", comment: "Cancel button label"), role: .cancel) { deleteAlert.toggle() }
                    
                        } message: {
                            Text("Are you sure you want to delete '\(switchName)'?", comment: "Message in alert for deleting switch")
                        }

                    })
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text(
                            "Cancel",
                            comment: "The cancel toolbar button to stop adding a new switch"
                        )
                    })
                }
                
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            createUpdateSwitch()
                            
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Save", comment: "The label for the save changes button")
                        })
                    }
                
            }
            .navigationTitle(
                String(
                    localized: "Switch: \(switchName)",
                    comment: "The navigation title when editing a given switch. It contains the user entered name after the colon"
                )
            )
        }
        
        .onAppear {
            initSwitchName()
        }
    }
    
    func createUpdateSwitch() {
        if let unwrappedId = id {
            // Update existing switch
            accessOptions.updateSwitch(
                id: unwrappedId,
                name: switchName,
                key: selectedKey ?? .keyboardEscape,
                tapAction: tapAction,
                holdAction: holdAction
            )
        } else {
            // Create new switch
            accessOptions.addSwitch(
                name: switchName,
                key: selectedKey ?? .keyboardEscape,
                tapAction: tapAction,
                holdAction: holdAction
            )
        }
        
    }
}

private struct PreviewWrapperAdd: View {
    @State var sheetState: Bool = true
    @StateObject var accessOptions = AccessOptions()
    
    var body: some View {
        
        Button(action: {
            sheetState.toggle()
        }, label: {
            Text("Open", comment: "Label for open button (preview only)")
        })
            .sheet(isPresented: $sheetState) {
                AddSwitch()
                    .environmentObject(accessOptions)
            }
        
    }
}

private struct PreviewWrapperEdit: View {
    @StateObject var accessOptions = AccessOptions()
    
    var body: some View {
        
        NavigationStack {
            Text("Main Page", comment: "Placeholder text for preview")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    navigationDestination(isPresented: .constant(true), destination: {
                        AddSwitch(
                            switchName: "My Switch",
                            selectedKey: .keyboardUpArrow,
                            tapAction: .nextNode,
                            id: UUID()
                        )
                            .environmentObject(accessOptions)
                            
                    })
                    
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }

    }
}

// periphery:ignore
struct AddSwitch_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        PreviewWrapperAdd()
        PreviewWrapperEdit()

    }
}
