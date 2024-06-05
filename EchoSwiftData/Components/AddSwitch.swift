//
//  AddSwitch.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 04/06/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct DetectSwitch: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // periphery:ignore
    @Bindable var currentSwitch: Switch
    
    var body: some View {
        ZStack {
            KeyboardPressDetectorView { press in
                self.currentSwitch.key = press.key?.keyCode
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
                AddSwitch(currentSwitch: $currentSwitch)
            }
    }
}

struct AddSwitch: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var currentSwitch: Switch?
    @State var deleteAlert: Bool = false
    
    @Environment(\.modelContext) var modelContext
    
    @Query var switches: [Switch]
    
    var body: some View {
        NavigationStack {
            
            if let unwrappedSwitch = currentSwitch {
                @Bindable var bindableSwitch = unwrappedSwitch

                Form {
                    Section(content: {
                        TextField(
                            String(localized: "Switch Name", comment: "Label for switch name TextField"),
                            text: $bindableSwitch.name,
                            prompt: Text("Required", comment: "Prompt for required text input"))
                    }, header: {
                        Text("Switch Name", comment: "Label shown on the switch name input")
                    })
                    Section(content: {
                        if let unwrappedKey = bindableSwitch.key {
                            HStack {
                                Text("Selected Key", comment: "Label for showing the value of the key that has been selected for an external switch")
                                Spacer()
                                Text(keyToDisplay(unwrappedKey))
                                    .foregroundStyle(.gray)
                            }
                        }
                        NavigationLink(destination: {
                            DetectSwitch(currentSwitch: bindableSwitch)
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
                            actions: SwitchAction.tapCases,
                            actionChange: { newAction in
                                bindableSwitch.tapAction = newAction
                            },
                            actionState: bindableSwitch.tapAction
                        )
                       
                        ActionPicker(
                            label: String(
                                localized: "Hold",
                                comment: "The label that is shown next to the single hold action"
                            ),
                            actions: SwitchAction.holdCases,
                            actionChange: { newAction in
                                bindableSwitch.holdAction = newAction
                            },
                            actionState: bindableSwitch.holdAction
                        )

                    }, header: {
                        Text("Actions", comment: "The header of the actions area when adding a new switch")
                    }, footer: {
                        Text(
                            "These are the actions that will happen when you tap or hold your switch",
                            comment: "The footer description of the area of the actions area when adding a new switch"
                        )
                    })
                    
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
                                if let unwrappedSwitch = currentSwitch {
                                    modelContext.delete(unwrappedSwitch)
                                    currentSwitch = nil
                                }
                                
                                
                                presentationMode.wrappedValue.dismiss()
                            }
                            Button(String(localized: "Cancel", comment: "Cancel button label"), role: .cancel) { deleteAlert.toggle() }
                    
                        } message: {
                            Text("Are you sure you want to delete '\(currentSwitch?.name ?? "UNKNOWN")'?", comment: "Message in alert for deleting switch")
                        }

                    })
                }
                
                
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Text("Save", comment: "The label for the save changes button")
                        })
                    }
                    
                }
                .navigationTitle(
                    currentSwitch != nil ? String(
                        localized: "Switch: \(currentSwitch?.name ?? "")",
                        comment: "The navigation title when editing a given switch. It contains the user entered name after the colon"
                    ) : String(
                        localized: "New Switch",
                        comment: "The navigation title when adding a given switch."
                    )
                )
            }
        }
        .onAppear {
            if currentSwitch == nil {
                let newSwitch = Switch(name: "Switch: \(switches.count + 1)", key: .keypadEnter)
                
                modelContext.insert(newSwitch)

                currentSwitch = newSwitch
            }
        }
    }
}
