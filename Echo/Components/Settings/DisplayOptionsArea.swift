import SwiftUI

struct DisplayOptionsArea: View {
    @Environment(Settings.self) var settings: Settings
    
    let colorOptions: [(String, Color)] = [
        ("System Color", .primary),
        ("Yellow", .yellow),
        ("Black", .black),
        ("Red", .red),
        ("Green", .green),
        ("Blue", .blue)
    ]

    var body: some View {
        @Bindable var settingsBindable = settings
        Form {
            // Section for Highlight Color Options
            Section(header: Text("Select Highlight Color")) {
                ForEach(colorOptions, id: \.0) { name, color in
                    Button(action: {
                        settings.highlightColor = name.lowercased()
                    }) {
                        HStack {
                            Rectangle()
                                .fill(color)
                                .frame(width: 20, height: 20)
                                .cornerRadius(3)
                            Text(name)
                            Spacer()
                            if settings.highlightColor == name.lowercased() {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }

                // Toggle for Bold Highlight Text
                Toggle(isOn: $settingsBindable.isHighlightTextBold) {
                    Text("Bold Highlight Text")
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
                        Text("\(settings.messageBarFontSize)")
                    }
                }

                // Color Options for Message Bar
                ForEach(colorOptions, id: \.0) { name, color in
                    Button(action: {
                        settings.messageBarColor = name.lowercased()
                    }) {
                        HStack {
                            Rectangle()
                                .fill(color)
                                .frame(width: 20, height: 20)
                                .cornerRadius(3)
                            Text(name)
                            Spacer()
                            if settings.messageBarColor == name.lowercased() {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }

                // Toggle for Bold Message Bar Text
                Toggle(isOn: $settingsBindable.isMessageBarTextBold) {
                    Text("Bold Message Bar Text")
                }
            }
        }
        .navigationTitle("Display Options")
    }
}
