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
        print("🔊 DEBUG: VoicePicker.init() called with voiceId: \(voiceId.wrappedValue), voiceName: \(voiceName.wrappedValue)")
        self._voiceId = voiceId
        self._voiceName = voiceName
        print("🔊 DEBUG: VoicePicker.init() completed")
    }
    
    var body: some View {
        let _ = print("🔊 DEBUG: VoicePicker body being rendered, isLoading: \(isLoading)")
        return NavigationView {
            VStack {
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Loading voices...")
                    }
                    .padding()
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
                    .padding(.top)

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
            print("🔊 DEBUG: VoicePicker onAppear called")
            loadVoicesAsync()
        }
    }

    private func loadVoicesAsync() {
        print("🔊 DEBUG: VoicePicker.loadVoicesAsync() called")
        DispatchQueue.global(qos: .userInitiated).async {
            print("🔊 DEBUG: Loading voices on background thread")
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
            print("🔊 DEBUG: VoicePicker.filteredVoiceLanguages() called but still loading")
            return []
        }
        print("🔊 DEBUG: VoicePicker.filteredVoiceLanguages() called")
        let allLanguages = voiceList.sortedKeys()
        print("🔊 DEBUG: Found \(allLanguages.count) voice languages")
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
