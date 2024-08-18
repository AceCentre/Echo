//
//  MessageBar.swift
// Echo
//
//  Created by Gavin Henderson on 08/07/2024.
//

import Foundation
import SwiftUI

struct MessageBar: View {
    @Environment(Settings.self) var settings: Settings
    
    @ObservedObject var mainCommunicationPageState: MainCommunicationPageState
    
    var body: some View {
        let backgroundColor = ColorOption.colorFromName(settings.messageBarBackgroundColorName).color

        VStack {
            let currentText = mainCommunicationPageState.enteredText
            let textColor = ColorOption.colorFromName(settings.messageBarTextColorName).color

            Text(currentText.isEmpty ? " " : currentText)
                .padding(10)
                .font(.system(size: CGFloat(settings.messageBarFontSize)))
                .fontWeight(settings.isMessageBarTextBold ? .bold : .regular) // Apply bold based on settings
                .foregroundColor(textColor.opacity(settings.messageBarTextOpacity)) // Apply text color and opacity

        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor.opacity(settings.messageBarBackgroundOpacity))
        .shadow(radius: 1)
    }
}
