//
//  Theme.swift
// Echo
//
//  Created by Will Wade on 15/08/2024.
//

import CoreGraphics
import UIKit

struct Theme {
    let name: String
    let lightVariant: ThemeVariant
    let darkVariant: ThemeVariant
    
    struct ThemeVariant {
        let highlightColor: String
        let highlightOpacity: Double
        let isHighlightTextBold: Bool
        let useCustomHighlightFontSize: Bool
        let highlightFontSize: Int
        let highlightFontName: String

        let entriesColor: String
        let entriesOpacity: Double
        let useCustomEntriesFontSize: Bool
        let entriesFontSize: Int
        let entriesFontName: String

        let messageBarTextColor: String
        let messageBarTextOpacity: Double
        let messageBarBackgroundColor: String
        let messageBarBackgroundOpacity: Double
        let messageBarFontName: String
        let messageBarFontSize: Int
    }
    
    static let themes = [
        // System Default
        Theme(
            name: "System Default",
            lightVariant: ThemeVariant(
                highlightColor: "System Default",
                highlightOpacity: 1.0,
                isHighlightTextBold: false,
                useCustomHighlightFontSize: false,
                highlightFontSize: Int(UIFont.preferredFont(forTextStyle: .body).pointSize),
                highlightFontName: "System",
                
                entriesColor: "System Default",
                entriesOpacity: 1.0,
                useCustomEntriesFontSize: false,
                entriesFontSize: Int(UIFont.preferredFont(forTextStyle: .body).pointSize),
                entriesFontName: "System",
                
                messageBarTextColor: "System Default",
                messageBarTextOpacity: 1.0,
                messageBarBackgroundColor: "Light Gray",
                messageBarBackgroundOpacity: 1.0,
                messageBarFontName: "System",
                messageBarFontSize: Int(UIFont.preferredFont(forTextStyle: .body).pointSize)
            ),
            darkVariant: ThemeVariant(
                highlightColor: "System Default",
                highlightOpacity: 1.0,
                isHighlightTextBold: false,
                useCustomHighlightFontSize: false,
                highlightFontSize: Int(UIFont.preferredFont(forTextStyle: .body).pointSize),
                highlightFontName: "System",
                
                entriesColor: "System Default",
                entriesOpacity: 1.0,
                useCustomEntriesFontSize: false,
                entriesFontSize: Int(UIFont.preferredFont(forTextStyle: .body).pointSize),
                entriesFontName: "System",
                
                messageBarTextColor: "System Default",
                messageBarTextOpacity: 1.0,
                messageBarBackgroundColor: "Dark Gray",
                messageBarBackgroundOpacity: 1.0,
                messageBarFontName: "System",
                messageBarFontSize: Int(UIFont.preferredFont(forTextStyle: .body).pointSize)
            )
        ),
        // High Contrast - Yellow on Black
        Theme(
            name: "High Contrast - Yellow",
            lightVariant: ThemeVariant(
                highlightColor: "Yellow",
                highlightOpacity: 1.0,
                isHighlightTextBold: true,
                useCustomHighlightFontSize: true,
                highlightFontSize: 32,
                highlightFontName: "Arial",
                
                entriesColor: "Dark Gray",
                entriesOpacity: 0.8,
                useCustomEntriesFontSize: true,
                entriesFontSize: 28,
                entriesFontName: "Arial",
                
                messageBarTextColor: "Black",
                messageBarTextOpacity: 1.0,
                messageBarBackgroundColor: "Yellow",
                messageBarBackgroundOpacity: 1.0,
                messageBarFontName: "Arial",
                messageBarFontSize: 32
            ),
            darkVariant: ThemeVariant(
                highlightColor: "Yellow",
                highlightOpacity: 1.0,
                isHighlightTextBold: true,
                useCustomHighlightFontSize: true,
                highlightFontSize: 32,
                highlightFontName: "Arial",
                
                entriesColor: "Yellow",
                entriesOpacity: 0.8,
                useCustomEntriesFontSize: true,
                entriesFontSize: 28,
                entriesFontName: "Arial",
                
                messageBarTextColor: "Yellow",
                messageBarTextOpacity: 1.0,
                messageBarBackgroundColor: "Dark Gray",
                messageBarBackgroundOpacity: 1.0,
                messageBarFontName: "Arial",
                messageBarFontSize: 32
            )
        ),
        // Muted - Mint
        Theme(
            name: "Muted - Mint",
            lightVariant: ThemeVariant(
                highlightColor: "Mint",
                highlightOpacity: 0.8,
                isHighlightTextBold: false,
                useCustomHighlightFontSize: true,
                highlightFontSize: 18,
                highlightFontName: "Georgia",
                
                entriesColor: "Black",
                entriesOpacity: 0.5,
                useCustomEntriesFontSize: true,
                entriesFontSize: 16,
                entriesFontName: "Georgia",
                
                messageBarTextColor: "Mint",
                messageBarTextOpacity: 0.8,
                messageBarBackgroundColor: "White",
                messageBarBackgroundOpacity: 1.0,
                messageBarFontName: "Georgia",
                messageBarFontSize: 18
            ),
            darkVariant: ThemeVariant(
                highlightColor: "Mint",
                highlightOpacity: 0.8,
                isHighlightTextBold: false,
                useCustomHighlightFontSize: true,
                highlightFontSize: 18,
                highlightFontName: "Georgia",
                
                entriesColor: "White",
                entriesOpacity: 0.5,
                useCustomEntriesFontSize: true,
                entriesFontSize: 16,
                entriesFontName: "Georgia",
                
                messageBarTextColor: "Mint",
                messageBarTextOpacity: 0.8,
                messageBarBackgroundColor: "Dark Gray",
                messageBarBackgroundOpacity: 1.0,
                messageBarFontName: "Georgia",
                messageBarFontSize: 18
            )
        )

    ]
}
