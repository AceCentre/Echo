//
//  DisplayOptionsArea.swift
//  Echo
//
//  Created by Will Wade on 15/08/2024.
//



import Foundation
import SwiftUI

struct AppearanceOptionsArea: View {
    @Environment(Settings.self) var settings
    let minArrowSize: CGFloat = 50.0
    let maxArrowSize: CGFloat = 300.0
    @State private var arrowSizePercentage: Double = 50.0
    @Environment(\.colorScheme) var colorScheme
    
    // Define availableFonts
    let availableFonts: [String] = {
        var fonts = ["System"] // Add "System" as a default option
        for family in UIFont.familyNames {
            fonts.append(contentsOf: UIFont.fontNames(forFamilyName: family))
        }
        return fonts
    }()

    var body: some View {
        @Bindable var settingsBindable = settings
        
        let messageBarBackgroundColor = ColorOption.colorFromName(settings.messageBarBackgroundColor).color
        let messageBarTextColor = ColorOption.colorFromName(settings.messageBarTextColor).color
        
        return VStack {
            Form {
                Section(header: Text("Theme")) {
                    Picker("Select Theme", selection: $settingsBindable.selectedTheme) {
                        ForEach(Theme.themes, id: \.name) { theme in
                            Text(theme.name)
                                .tag(theme.name)
                        }
                    }
                    .onChange(of: settings.selectedTheme) { oldThemeName, newThemeName in
                        if let selectedTheme = Theme.themes.first(where: { $0.name == newThemeName }) {
                            settings.applyTheme(selectedTheme, for: colorScheme)
                        }
                    }
                    .onChange(of: colorScheme) { oldColorScheme, newColorScheme in
                        if let selectedTheme = Theme.themes.first(where: { $0.name == settings.selectedTheme }) {
                            settings.applyTheme(selectedTheme, for: newColorScheme)
                        }
                    }
                }
                
                // Section for Highlight Color Options
                Section(header: Text("Select Highlight Color")) {
                    Toggle("Use Custom Font Size", isOn: $settingsBindable.useCustomHighlightFontSize)
                    
                    if settings.useCustomHighlightFontSize {
                        Stepper("Font Size: \(settings.highlightFontSize)", value: $settingsBindable.highlightFontSize, in: 10...100)
                    }
                    Picker("Select Font", selection: $settingsBindable.highlightFontName) {
                        ForEach(availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                    
                    Picker("Select Highlight Color", selection: $settingsBindable.highlightColor) {
                        ForEach(ColorOption.colorOptions) { colorOption in
                            colorOptionView(for: colorOption)
                        }
                    }
                    
                    // Slider for Highlight Color Opacity
                    Slider(value: $settingsBindable.highlightOpacity, in: 0.0...1.0)
                    Text("Opacity: \(Int(settingsBindable.highlightOpacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Toggle for Bold Highlight Text
                    Toggle(isOn: $settingsBindable.isHighlightTextBold) {
                        Text("Bold Highlight Text")
                    }
                    
                    // Preview for Highlight Text
                    highlightTextPreview()
                    
                }
                
                Section(header: Text("All other items")) {
                    Toggle("Use Custom Font Size", isOn: $settingsBindable.useCustomEntriesFontSize)
                    
                    if settings.useCustomEntriesFontSize {
                        Stepper("Font Size: \(Int(settings.entriesFontSize))", value: $settingsBindable.entriesFontSize, in: 10...100)
                    }
                    Picker("Select Font", selection: $settingsBindable.entriesFontName) {
                        ForEach(availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                    Picker("All other items color", selection: $settingsBindable.entriesColor) {
                        ForEach(ColorOption.colorOptions) { colorOption in
                            colorOptionView(for: colorOption)
                        }
                    }
                    
                    // Slider for Highlight Color Opacity
                    Slider(value: $settingsBindable.entriesOpacity, in: 0.0...1.0)
                    Text("Opacity: \(Int(settingsBindable.entriesOpacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Preview for Highlight Text
                    entriesTextPreview()
                    
                }
                
                // Section for Message Bar Settings
                Section(header: Text("Message Bar")) {
                                    
                    Picker("Select Font", selection: $settingsBindable.messageBarFontName) {
                        ForEach(availableFonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                    // Stepper for Font Size
                    Stepper(
                        value: $settingsBindable.messageBarFontSize,
                        in: 10...100,
                        step: 1
                    ) {
                        HStack {
                            Text("Message Bar Font Size")
                            Spacer()
                            Text("\(settingsBindable.messageBarFontSize)")
                        }
                    }                    
                    // Picker for Message Bar Background Color
                    Picker("Select Message Bar Background Color", selection: $settingsBindable.messageBarBackgroundColor) {
                        ForEach(ColorOption.colorOptions) { colorOption in
                            colorOptionView(for: colorOption)
                        }
                    }
                    
                    // Slider for Background Opacity
                    Slider(value: $settingsBindable.messageBarBackgroundOpacity, in: 0.0...1.0)
                    Text("Background Opacity: \(Int(settingsBindable.messageBarBackgroundOpacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Picker for Message Bar Text Color
                    Picker("Select Message Bar Text Color", selection: $settingsBindable.messageBarTextColor) {
                        ForEach(ColorOption.colorOptions) { colorOption in
                            colorOptionView(for: colorOption)
                        }
                    }
                    
                    // Slider for Text Opacity
                    
                    Slider(value: $settingsBindable.messageBarTextOpacity, in: 0.0...1.0)
                    Text("Text Opacity: \(Int(settingsBindable.messageBarTextOpacity * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Toggle for Bold Message Bar Text
                    Toggle(isOn: $settingsBindable.isMessageBarTextBold) {
                        Text("Bold Message Bar Text")
                    }
                    
                    // Preview for Message Bar Text
                    messageBarTextPreview(
                        backgroundColor: messageBarBackgroundColor,
                        textColor: messageBarTextColor
                    )
                    
                }
                
                if settings.showOnScreenArrows {
                    Section(header: Text("On-Screen Arrow")) {
                        // Percentage slider to adjust arrow size
                        Slider(value: $arrowSizePercentage, in: 0...100, onEditingChanged: { _ in
                            // Calculate the actual arrow size based on the percentage when the slider stops moving
                            settings.arrowSize = minArrowSize + (maxArrowSize - minArrowSize) * CGFloat(arrowSizePercentage / 100)
                            print("Arrow Size Percentage: \(arrowSizePercentage)%")
                            print("Corresponding Actual Arrow Size: \(settings.arrowSize)")
                        })
                        
                        // Display the percentage for reference
                        Text("Arrow Size: \(Int(arrowSizePercentage)) %")
                        
                        Slider(value: $settingsBindable.arrowBorderOpacity, in: 0.0...1.0, step: 0.01)
                        Text("Arrow Border Opacity: \(Int(settings.arrowBorderOpacity * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onAppear {
                        // Initialize the slider value based on the current arrow size
                        arrowSizePercentage = Double((settings.arrowSize - minArrowSize) / (maxArrowSize - minArrowSize) * 100)
                    }
                }
                
            }
            .navigationTitle("Appearance Options")
        }
    }
    
    
    // Helper function to reduce complexity in the body
    private func colorOptionView(for colorOption: ColorOption) -> some View {
        HStack {
            Rectangle()
                .fill(colorOption.color)
                .frame(width: 20, height: 20)
                .cornerRadius(3)
            Text(colorOption.name)
        }
        .tag(colorOption.name)
    }
    
    // Helper function to preview the highlight text
    private func highlightTextPreview() -> some View {
        let highlightColor = ColorOption.colorFromName(settings.highlightColor).color
        let highlightColorWithOpacity = highlightColor.opacity(settings.highlightOpacity)
        
        return Text("Sample Highlight Text")
            .padding()
            .foregroundColor(highlightColorWithOpacity)
            .font(
                .custom(
                    settings.highlightFontName,
                    size: settings.useCustomHighlightFontSize
                        ? CGFloat(settings.highlightFontSize)
                        : UIFont.preferredFont(forTextStyle: .body).pointSize
                )
            )
            .fontWeight(settings.isHighlightTextBold ? .bold : .regular)
    }
    
    private func entriesTextPreview() -> some View {
        let entriesColor = ColorOption.colorFromName(settings.entriesColor).color
        let entriesColorWithOpacity = entriesColor.opacity(settings.entriesOpacity)
        
        return Text("Sample Entries Text")
            .padding()
            .foregroundColor(entriesColorWithOpacity)
            .font(
                .custom(
                    settings.entriesFontName,
                    size: settings.useCustomEntriesFontSize
                        ? CGFloat(settings.entriesFontSize)
                        : UIFont.preferredFont(forTextStyle: .body).pointSize
                )
            )
    }

    
    // Updated helper function to preview the message bar text
    private func messageBarTextPreview(backgroundColor: Color, textColor: Color) -> some View {
        Text("Sample Message Bar Text")
            .padding()
            .font(
                .custom(
                    settings.messageBarFontName,
                    size: CGFloat(settings.messageBarFontSize)
                )
            )
            .foregroundColor(textColor.opacity(settings.messageBarTextOpacity))
            .fontWeight(settings.isMessageBarTextBold ? .bold : .regular)
            .background(backgroundColor.opacity(settings.messageBarBackgroundOpacity))
    }
}


