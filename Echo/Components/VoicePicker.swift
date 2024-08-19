import Foundation
import SwiftUI
import AVFAudio

struct VoicePicker: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var voiceList = AvailableVoices()
    
    @Binding var voiceId: String
    @Binding var voiceName: String
    
    @State private var searchText: String = ""
    @State private var showNoveltyVoices: Bool = false
    
    var body: some View {
        Form {
            // Search Bar
            Section {
                TextField("Search by language or name", text: $searchText)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }

            // Toggle for Novelty Voices
            Section {
                Toggle("Show Novelty Voices", isOn: $showNoveltyVoices)
            }

            // List of voices filtered by search text and novelty toggle
            ForEach(filteredVoiceLanguages(), id: \.self) { lang in
                Section(header: Text(getLanguageAndRegion(lang))) {
                    let voices = filteredVoices(for: lang)
                    ForEach(Array(voices.enumerated()), id: \.element.identifier) { _, voice in
                        Button(action: {
                            voiceId = voice.identifier
                            voiceName = "\(voice.name) (\(getLanguage(voice.language)))"
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Text(voice.name)
                                    .foregroundStyle(colorScheme == .light ? .black : .white)
                                Spacer()
                                if voiceId == voice.identifier {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select a Voice")
    }

    // Filtered list of voice languages based on search and novelty filter
    private func filteredVoiceLanguages() -> [String] {
        let allLanguages = voiceList.sortedKeys()
        let matchingLanguages = allLanguages.filter { lang in
            let voices = filteredVoices(for: lang)
            return !voices.isEmpty
        }
        return matchingLanguages
    }
    
    private func filteredVoices(for lang: String) -> [AVSpeechSynthesisVoice] {
        return voiceList.voicesForLang(lang).filter { voice in
            let matchesSearch = searchText.isEmpty ||
            voice.name.localizedCaseInsensitiveContains(searchText) ||
            getLanguage(voice.language).localizedCaseInsensitiveContains(searchText)
            
            var isNovelty = false
            
            if #available(iOS 17.0, *) {
                let traits = voice.voiceTraits
                isNovelty = traits.contains(.isNoveltyVoice)
            }
            
            // Return true if the search matches and the novelty filter is satisfied
            return matchesSearch && (showNoveltyVoices || !isNovelty)
        }
        
    }
}
