//
//  MessageBar.swift
//  EchoSwiftData
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
            
            Text(currentText == "" ? " " : currentText)
                .padding(10)
                .font(.system(size: CGFloat(settings.messageBarFontSize)))
        }
        .frame(maxWidth: .infinity)
        .background(Color("lightGray"))
        .shadow(radius: 1)
    }
}
