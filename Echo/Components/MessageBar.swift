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
        VStack {
            let currentText = mainCommunicationPageState.enteredText
            let selectedColorOption = ColorOption.colorFromName(settings.messageBarColorName)
                    

            Text(currentText.isEmpty ? " " : currentText)
                        .padding(10)
                        .font(.system(size: CGFloat(settings.messageBarFontSize)))
                        .fontWeight(settings.isMessageBarTextBold ? .bold : .regular) // Apply bold based on settings
                        .foregroundColor(selectedColorOption.color.opacity(settings.messageBarOpacity))

        }
        .frame(maxWidth: .infinity)
        .background(Color("lightGray"))
        .shadow(radius: 1)
    }
}
