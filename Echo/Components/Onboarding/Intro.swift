//
//  Intro.swift
// Echo
//
//  Created by Gavin Henderson on 24/05/2024.
//

import Foundation
import SwiftUI
import WebKit

struct DemoGif: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        if let url = Bundle.main.url(forResource: "EchoDemo", withExtension: "gif") {
            do {
                let data = try Data(contentsOf: url)
                
                webView.load(
                    data,
                    mimeType: "image/gif",
                    characterEncodingName: "UTF-8",
                    baseURL: url.deletingLastPathComponent()
                )
            } catch {
                print("An error occurred whilst loading image")
            }
            webView.scrollView.isScrollEnabled = false
        }
        
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.reload()
    }

}

struct IntroStep: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                DemoGif().aspectRatio(970 / 1920, contentMode: .fit)
                Spacer()
            }

            BottomText(
                topText: AttributedString(
                    localized: "Welcome to **Echo**",
                    comment: "Welcome message in onboarding"
                ),
                bottomText: AttributedString(
                    localized: "Every Character Speaks Volumes",
                    comment: "Explain what Echo is"
                )
            )
        }
    }
}
