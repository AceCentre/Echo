//
//  SettingsPage.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 07/06/2024.
//

import Foundation
import SwiftUI


enum SettingsPath: CaseIterable, Identifiable {
    case voice, access, scanning, spelling, onboarding, externalLinks, audio, vocabulary
    
    // periphery:ignore
    static public var allPhonePages: [SettingsPath] = [.voice, .access, .scanning, .spelling, .audio, .vocabulary]
    // periphery:ignore
    static public var allPadPages: [SettingsPath] = [.voice, .access, .scanning, .spelling, .audio, .vocabulary, .onboarding, .externalLinks]
    
    var id: String {
        switch self {
        case .voice: return "voice"
        case .access: return "access"
        case .scanning: return "scanning"
        case .spelling: return "spelling"
        case .onboarding: return "onboarding"
        case .externalLinks: return "external"
        case .audio: return "audio"
        case .vocabulary: return "vocabulary"
        }
    }
    
    @ViewBuilder var page: some View {
        switch self {
        case .voice: VoiceSelectionArea()
        case .access: AccessOptionsArea()
        case .scanning: ScanningOptionsArea()
        case .spelling: SpellingOptionsArea()
        case .onboarding: OnboardingSettingsPage()
        case .externalLinks: ExternalLinksForm()
        case .audio: Text("Test")
        case .vocabulary: Text("Test")
        }
    }
    
    var description: String {
        switch self {
        case .voice: return String(
            localized: "Voice Selection",
            comment: "Label for the navigation link to the voice options page"
        )
        case .access: return String(
            localized: "Access Methods",
            comment: "Label for the navigation link to the access methods options page"
        )
        case .scanning: return String(
            localized: "Scanning",
            comment: "Label for the navigation link to the scanning options page"
        )
        case .spelling: return String(
            localized: "Spelling & Alphabet",
            comment: "Label for the navigation link to the spelling, alphabet and predictions options page"
        )
        case .onboarding: return String(
            localized: "Initial Setup",
            comment: "Label for the navigation link to the initial options page"
        )
        case .externalLinks: return String(
            localized: "External Links",
            comment: "Label for the navigation link to the externalLinks options page"
        )
        case .audio: return String(
            localized: "Audio",
            comment: "Label for the navigation link to the audio options page"
        )
        case .vocabulary: return String(
            localized: "Vocabulary",
            comment: "Label for navigation link to the vocab page"
        )
        }
    }
}

struct SettingsPagePhone: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Form {
            Group {
                ForEach(SettingsPath.allPhonePages) { settingPage in
                    NavigationLink(destination: {
                        settingPage.page
                    }, label: {
                        Text(settingPage.description)
                    })
                }
            }
            Section {
                NavigationLink(destination: {
                    OnboardingSettingsPage()
                }, label: {
                    Text("Initial Setup", comment: "Label for the navigation link to the onboarding page")
                })
            }
            
            ExternalLinksSection()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(
            String(
                localized: "Settings",
                comment: "The navigation title for the settings page"
            )
        )
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back", comment: "The button text for the navigation back button")
                    }
                })
            }
        }
    }
}

struct SettingsPagePad: View {
    @State private var selection: SettingsPath? = .voice
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationSplitView {
            List(SettingsPath.allPadPages, id: \.self, selection: $selection) { path in
                NavigationLink(path.description, value: path)
            }
        } detail: {
            if let unwrappedSelection = selection {
                unwrappedSelection.page
            } else {
                VoiceSelectionArea()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle(
            String(
                localized: "Settings",
                comment: "The navigation title for the settings page"
            )
        )
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back", comment: "The button text for the navigation back button")
                    }
                })
            }
        }
    }
}

struct SettingsPage: View {
    @StateObject var rating: Rating = Rating()
    
    var body: some View {
        ZStack {
            if UIDevice.current.userInterfaceIdiom == .pad {
                SettingsPagePad()
            } else {
                SettingsPagePhone()
            }
        }.onAppear {
            if rating.shouldShowRating() {
                rating.openPrompt()
            }
        }
    }
}
