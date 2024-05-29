//
//  BottomText.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 24/05/2024.
//

import Foundation
import SwiftUI

struct BottomText: View {
    var topText: AttributedString
    var bottomText: AttributedString
    
    var body: some View {
        Text(topText)
            .foregroundStyle(Color("aceBlue"))
            .font(.system(size: 24))
            .padding(.bottom, 4)
            .multilineTextAlignment(.center)
        Text(bottomText)
            .foregroundStyle(Color("aceBlue"))
            .font(.system(size: 18))
            .multilineTextAlignment(.center)
    }
}
