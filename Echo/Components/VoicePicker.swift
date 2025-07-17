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
    @State private var isLoading: Bool = true

    init(voiceId: Binding<String>, voiceName: Binding<String>) {
        self._voiceId = voiceId
        self._voiceName = voiceName
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading voices...")
                    }
                    Spacer()
                } else {
                    // Search field at the top
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search by voice name or language", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding(.horizontal)

                    Form {
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
                }
            }
            .navigationTitle("Select a Voice")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            // print("🔊 DEBUG: VoicePicker onAppear called")
            loadVoicesAsync()
        }
    }

    private func loadVoicesAsync() {
        // print("🔊 DEBUG: VoicePicker.loadVoicesAsync() called")
        DispatchQueue.global(qos: .userInitiated).async {
            //print("🔊 DEBUG: Loading voices on background thread")
            // This will trigger ensureInitialized() on background thread
            let _ = voiceList.sortedKeys()

            DispatchQueue.main.async {
                print("🔊 DEBUG: Voice loading completed, updating UI")
                isLoading = false
            }
        }
    }

    // Filtered list of voice languages based on search and novelty filter
    func filteredVoiceLanguages() -> [String] {
        guard !isLoading else {
            return []
        }
        let allLanguages = voiceList.sortedKeys()
        let matchingLanguages = allLanguages.filter { lang in
            let voices = filteredVoices(for: lang)
            return !voices.isEmpty
        }
        return matchingLanguages
    }
    
    func filteredVoices(for lang: String) -> [AVSpeechSynthesisVoice] {
        return voiceList.voicesForLang(lang).filter { voice in
            let matchesSearch = searchText.isEmpty ||
            voice.name.localizedCaseInsensitiveContains(searchText) ||
            getLanguage(voice.language).localizedCaseInsensitiveContains(searchText) ||
            getLanguageAndRegion(voice.language).localizedCaseInsensitiveContains(searchText) ||
            voice.language.localizedCaseInsensitiveContains(searchText) ||
            voice.identifier.localizedCaseInsensitiveContains(searchText)

            var isNovelty = false
            var isEnhanced = false

            if #available(iOS 17.0, *) {
                let traits = voice.voiceTraits
                isNovelty = traits.contains(.isNoveltyVoice)
            }

            // Additional novelty voice detection for voices that might not have the trait set correctly
            // Eloquence voices should be considered novelty voices
            if voice.identifier.contains("eloquence") {
                isNovelty = true
            }

            // Other novelty voice patterns
            if voice.identifier.contains("novelty") || voice.name.localizedCaseInsensitiveContains("novelty") {
                isNovelty = true
            }

            // Check if it's an enhanced voice
            isEnhanced = voice.identifier.contains("enhanced")

            // Additional search terms
            let additionalMatches = searchText.isEmpty ||
            (searchText.localizedCaseInsensitiveContains("enhanced") && isEnhanced) ||
            (searchText.localizedCaseInsensitiveContains("compact") && voice.identifier.contains("compact")) ||
            (searchText.localizedCaseInsensitiveContains("premium") && voice.identifier.contains("premium"))

            let finalSearchMatch = matchesSearch || additionalMatches

            // Return true if the search matches and the novelty filter is satisfied
            return finalSearchMatch && (showNoveltyVoices || !isNovelty)
        }

    }
}
