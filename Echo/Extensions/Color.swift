import Foundation
import SwiftUI

struct ColorOption: Identifiable {
    let name: String
    let color: Color
    var id: String { name }
    
    // Static property for accessing all color options
    static let colorOptions: [ColorOption] = [
        ColorOption(name: "Black", color: .black),
        ColorOption(name: "Blue", color: .blue),
        ColorOption(name: "Brown", color: .brown),
        ColorOption(name: "Cyan", color: .cyan),
        ColorOption(name: "Gray", color: .gray),
        ColorOption(name: "Light Gray", color: .lightGray),
        ColorOption(name: "Dark Gray", color: Color(white: 0.33)),
        ColorOption(name: "Green", color: .green),
        ColorOption(name: "Indigo", color: .indigo),
        ColorOption(name: "Mint", color: .mint),
        ColorOption(name: "Orange", color: .orange),
        ColorOption(name: "Pink", color: .pink),
        ColorOption(name: "Purple", color: .purple),
        ColorOption(name: "Red", color: .red),
        ColorOption(name: "Teal", color: .teal),
        ColorOption(name: "White", color: .white),
        ColorOption(name: "Yellow", color: .yellow),
        ColorOption(name: "System Default", color: .primary)
    ]
    
    static func colorFromName(_ name: String, useSecondary: Bool = false) -> ColorOption {
            if let matchedOption = colorOptions.first(where: { $0.name.lowercased() == name.lowercased() }) {
                return matchedOption
            } else if name.lowercased() == "system default" {
                return ColorOption(name: "System Default", color: useSecondary ? .secondary : .primary)
            } else {
                return ColorOption(name: "Black", color: .black) // Default color if name doesn't match
            }
        }
}
