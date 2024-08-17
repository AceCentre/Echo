//
//  Themes.swift
//  Echo
//
//  Created by Will Wade on 17/08/2024.
//

import Foundation
extension Theme {
    static let themes: [Theme] = [
        Theme(name: "High Contrast - Yellow on Black",
              highlightColor: "yellow",
              highlightOpacity: 1.0,
              isHighlightTextBold: true,
              messageBarColorName: "yellow",
              messageBarBackgroundColorName: "black",
              messageBarTextColorName: "yellow",
              messageBarTextOpacity: 1.0,
              messageBarBackgroundOpacity: 1.0,
              messageBarFontSize: 20),
        
        Theme(name: "Muted - Mint",
              highlightColor: "mint",
              highlightOpacity: 0.8,
              isHighlightTextBold: false,
              messageBarColorName: "mint",
              messageBarBackgroundColorName: "white",
              messageBarTextColorName: "mint",
              messageBarTextOpacity: 0.8,
              messageBarBackgroundOpacity: 1.0,
              messageBarFontSize: 18),
        
        Theme(name: "System Default",
              highlightColor: "system color",
              highlightOpacity: 1.0,
              isHighlightTextBold: false,
              messageBarColorName: "system color",
              messageBarBackgroundColorName: "system color",
              messageBarTextColorName: "system color",
              messageBarTextOpacity: 1.0,
              messageBarBackgroundOpacity: 1.0,
              messageBarFontSize: 16)
    ]
}
