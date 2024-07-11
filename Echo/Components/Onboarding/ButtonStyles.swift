//
//  ButtonStyles.swift
// Echo
//
//  Created by Gavin Henderson on 24/05/2024.
//

import Foundation

import Foundation
import SwiftUI

struct NextButton: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 52)
            .padding(.vertical)
            .background(Color("aceBlue"))
            .foregroundStyle(colorScheme == .light ? .white : Color("gradientBackground"))
            .clipShape(Capsule())
            .fontWeight(.bold)
            .font(.system(size: 24))
    }
}

struct SkipButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 52)
            .padding(.vertical)
            .border(Color("aceBlue"), width: 2, cornerRadius: 32)
            .foregroundStyle(Color("aceBlue"))
            .fontWeight(.bold)
            .font(.system(size: 24))
    }
}
