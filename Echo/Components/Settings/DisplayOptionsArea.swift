//
//  DisplayOptionsArea.swift
//  Echo
//
//  Created by Will Wade on 15/08/2024.
//

import Foundation
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
                }
                
                Section(header: Text("Message Bar")) {
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
                }
            }
            .navigationTitle("Display Options")
        
        
        }
}
