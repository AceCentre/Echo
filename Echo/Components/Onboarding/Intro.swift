//
//  Intro.swift
//  Echo
//
//  Created by Gavin Henderson on 27/10/2023.
//

import Foundation
import SwiftUI
import AVKit

struct PlayerWrapper: UIViewControllerRepresentable {
    var videoURL: URL?

    private var player: AVPlayer {
        return AVPlayer(url: videoURL!)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        controller.player = player
        controller.player?.play()
        controller.videoGravity = .resizeAspectFill
        
        return controller
    }

    func updateUIViewController(_ playerController: AVPlayerViewController, context: Context) {}
}

struct IntroStep: View {
    @State var player: AVPlayer?
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                PlayerWrapper(videoURL: Bundle.main.url(forResource: "EchoIntro", withExtension: "mp4"))
                    .aspectRatio(970 / 1920, contentMode: .fit)
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
