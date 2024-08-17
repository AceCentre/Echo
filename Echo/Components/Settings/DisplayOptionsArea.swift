//
//  DisplayOptionsArea.swift
//  Echo
//
//  Created by Will Wade on 15/08/2024.
//



import Foundation
import SwiftUI

struct DisplayOptionsArea: View {
    @Environment(Settings.self) var settings
    
    var body: some View {
        @Bindable var settingsBindable = settings
        
        let messageBarBackgroundColor = ColorOption.colorFromName(settings.messageBarBackgroundColorName).color
        let messageBarTextColor = ColorOption.colorFromName(settings.messageBarTextColorName).color
        
        return VStack {
            Form {
                Section(header: Text("Theme")) {
                    Picker("Select Theme", selection: $settingsBindable.selectedTheme) {
                        ForEach(Theme.themes, id: \.name) { theme in
                            Text(theme.name)
                                .tag(theme.name)
                        }
                    }
                    .onChange(of: settings.selectedTheme) { newThemeName in
                        if let selectedTheme = Theme.themes.first(where: { $0.name == newThemeName }) {
                            settings.applyTheme(selectedTheme)
                        }
                    }

                }
                
                // Section for Highlight Color Options
                Section(header: Text("Select Highlight Color")) {
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
                    Section(header: Text("Highlight Text Preview")) {
                        highlightTextPreview()
                    }
                }
                
                // Section for Message Bar Settings
                Section(header: Text("Message Bar")) {
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
                    Picker("Select Message Bar Background Color", selection: $settingsBindable.messageBarBackgroundColorName) {
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
                    Picker("Select Message Bar Text Color", selection: $settingsBindable.messageBarTextColorName) {
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
                    Section(header: Text("Message Bar Text Preview")) {
                        messageBarTextPreview(
                            backgroundColor: messageBarBackgroundColor,
                            textColor: messageBarTextColor
                        )
                    }
                }
                if
                    settings.showOnScreenArrows {
                    Section(header: Text("On-Screen Arrow")) {
                        Stepper(value: $settingsBindable.arrowSize, in: 50...300, step: 10) {
                            Text("Arrow Size: \(Int(settings.arrowSize))")
                        }
                        
                        Slider(value: $settingsBindable.arrowBorderOpacity, in: 0.0...1.0, step: 0.1)
                        Text("Arrow Border Opacity: \(Int(settings.arrowBorderOpacity * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                    }
                }
                           
            }
            .navigationTitle("Display Options")
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
        .tag(colorOption.name.lowercased())
    }
    
    // Helper function to preview the highlight text
    private func highlightTextPreview() -> some View {
        let highlightColor = ColorOption.colorFromName(settings.highlightColor).color
        let highlightColorWithOpacity = highlightColor.opacity(settings.highlightOpacity)
        
        return Text("Sample Highlight Text")
            .padding()
            .foregroundColor(highlightColorWithOpacity)
            .fontWeight(settings.isHighlightTextBold ? .bold : .regular)
    }

    // Updated helper function to preview the message bar text
    private func messageBarTextPreview(backgroundColor: Color, textColor: Color) -> some View {
        Text("Sample Message Bar Text")
            .padding()
            .font(.system(size: CGFloat(settings.messageBarFontSize)))
            .foregroundColor(textColor.opacity(settings.messageBarTextOpacity))
            .fontWeight(settings.isMessageBarTextBold ? .bold : .regular)
            .background(backgroundColor.opacity(settings.messageBarBackgroundOpacity))
    }
}


