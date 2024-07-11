//
//  SheetButton.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 11/07/2024.
//

import Foundation
import SwiftUI

struct SheetButton<SheetLabel: View, SheetContent: View>: View {
    @ViewBuilder var sheetLabel: SheetLabel
    @ViewBuilder var sheetContent: SheetContent
    
    @State var isPresented = false
    
    var onDismiss: (() -> Void)?
    
    var body: some View {
        Button(action: {
            isPresented = true
        }, label: {
            sheetLabel
        }).sheet(isPresented: $isPresented, onDismiss: onDismiss, content: {
            sheetContent
        })
    }
}
