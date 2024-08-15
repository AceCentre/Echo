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
    
    let colorOptions: [(String, Color)] = [
            ("Yellow", .yellow),
            ("Black", .black),
            ("Red", .red),
            ("Green", .green),
            ("Blue", .blue)
        ]
    
    var body: some View {
            Form {
                Section(header: Text("Select Highlight Color")) {
                    ForEach(colorOptions, id: \.0) { name, color in
                        Button(action: {
                            settings.highlightColor = name.lowercased()
                        }) {
                            HStack {
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
            }
            .navigationTitle("Highlight Color")
        }
}
