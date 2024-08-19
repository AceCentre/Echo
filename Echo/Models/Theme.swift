struct Theme {
    let name: String
    let lightVariant: ThemeVariant
    let darkVariant: ThemeVariant
    
    struct ThemeVariant {
        let highlightColor: String
        let highlightOpacity: Double
        let isHighlightTextBold: Bool
        let entriesColor: String
        let entriesOpacity: Double
        let messageBarColorName: String
        let messageBarBackgroundColorName: String
        let messageBarTextColorName: String
        let messageBarTextOpacity: Double
        let messageBarBackgroundOpacity: Double
        let messageBarFontSize: Int
    }
    
    static let themes = [
        // High Contrast - Yellow on Black
        Theme(
            name: "High Contrast - Yellow",
            lightVariant: Theme.ThemeVariant(
                highlightColor: "Black", // Black highlight on Yellow background
                highlightOpacity: 1.0,
                isHighlightTextBold: true,
                entriesColor: "Dark Gray", // Yellow entries text
                entriesOpacity: 0.8,
                messageBarColorName: "Dark Gray",
                messageBarBackgroundColorName: "Yellow",
                messageBarTextColorName: "Black",
                messageBarTextOpacity: 1.0,
                messageBarBackgroundOpacity: 1.0,
                messageBarFontSize: 32 // Large font size
            ),
            darkVariant: Theme.ThemeVariant(
                highlightColor: "Yellow", // Yellow highlight on Dark Gray background
                highlightOpacity: 1.0,
                isHighlightTextBold: true,
                entriesColor: "Yellow", // Yellow entries text
                entriesOpacity: 0.8,
                messageBarColorName: "Yellow",
                messageBarBackgroundColorName: "Dark Gray",
                messageBarTextColorName: "Yellow",
                messageBarTextOpacity: 1.0,
                messageBarBackgroundOpacity: 1.0,
                messageBarFontSize: 22 // Large font size
            )
        ),
        // Muted - Mint
        Theme(
            name: "Muted - Mint",
            lightVariant: Theme.ThemeVariant(
                highlightColor: "Mint",
                highlightOpacity: 0.8,
                isHighlightTextBold: false,
                entriesColor: "Black", // Black text on white background
                entriesOpacity: 0.5,
                messageBarColorName: "Mint",
                messageBarBackgroundColorName: "White",
                messageBarTextColorName: "Mint",
                messageBarTextOpacity: 0.8,
                messageBarBackgroundOpacity: 1.0,
                messageBarFontSize: 18 // Standard font size
            ),
            darkVariant: Theme.ThemeVariant(
                highlightColor: "Mint",
                highlightOpacity: 0.8,
                isHighlightTextBold: false,
                entriesColor: "White", // White text on dark gray background
                entriesOpacity: 0.5,
                messageBarColorName: "Mint",
                messageBarBackgroundColorName: "Dark Gray",
                messageBarTextColorName: "Mint",
                messageBarTextOpacity: 0.8,
                messageBarBackgroundOpacity: 1.0,
                messageBarFontSize: 18 // Standard font size
            )
        ),
        // System Default
        Theme(
            name: "System Default",
            lightVariant: Theme.ThemeVariant(
                highlightColor: "System Default",
                highlightOpacity: 1.0,
                isHighlightTextBold: false,
                entriesColor: "System Default",
                entriesOpacity: 1.0,
                messageBarColorName: "System Default",
                messageBarBackgroundColorName: "Light Gray",
                messageBarTextColorName: "System Default",
                messageBarTextOpacity: 1.0,
                messageBarBackgroundOpacity: 1.0,
                messageBarFontSize: 16 // Standard font size
            ),
            darkVariant: Theme.ThemeVariant(
                highlightColor: "System Default",
                highlightOpacity: 1.0,
                isHighlightTextBold: false,
                entriesColor: "System Default",
                entriesOpacity: 1.0,
                messageBarColorName: "System Default",
                messageBarBackgroundColorName: "Dark Gray",
                messageBarTextColorName: "System Default",
                messageBarTextOpacity: 1.0,
                messageBarBackgroundOpacity: 1.0,
                messageBarFontSize: 16 // Standard font size
            )
        )
    ]
}
