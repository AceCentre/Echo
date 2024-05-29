//
//  Onboarding.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 24/05/2024.
//

import Foundation
import SwiftUI

enum OnboardingSteps: Int, CaseIterable, Identifiable {
    case introVideo = 0
    case secondStep = 1
    case vocabulary = 2
//    case cueVoice =  3
//    case speakingVoice = 4
//    case scanning = 5
//    case prediction = 6
//    case onScreenArrows = 7
//    case swipeOnboarding = 8
//    case switchOnboarding = 9
//    case analytics = 10

    var id: String {
        switch self {
        case .introVideo: "intro"
        case .secondStep: "second"
//        case .onScreenArrows: "arrows"
//        case .swipeOnboarding: "swipe"
//        case .cueVoice: "cueVoice"
//        case .speakingVoice: "speakingVoice"
//        case .analytics: "analytics"
//        case .prediction: "prediction"
//        case .switchOnboarding: "switch"
//        case .scanning: "Scanning"
        case .vocabulary: "Vocabulary"
        }
    }
    
    @ViewBuilder var page: some View {
        switch self {
        case .introVideo: IntroStep()
        case .secondStep: SecondStep()
//        case .onScreenArrows: OnScreenArrowsOnboarding()
//        case .swipeOnboarding: SwipeOnboarding()
//        case .cueVoice: CueVoiceOnboarding()
//        case .speakingVoice: SpeakingVoiceOnboarding()
//        case .analytics: AnalyticsOnboarding()
//        case .prediction: PredictionOnboarding()
//        case .switchOnboarding: SwitchOnboarding()
//        case .scanning: ScanningOnboarding()
        case .vocabulary: VocabularyOnboarding()
        }
    }
}

struct OnboardingSettingsPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Onboarding(endOnboarding: {
            self.presentationMode.wrappedValue.dismiss()
        })
    }
}

struct Onboarding: View {
    @State var currentPage: Int = 0
    @AccessibilityFocusState var isFocused: Bool
    var endOnboarding: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(stops: [
                    .init(color: Color("gradientBackground").opacity(0.3), location: 0),
                    .init(color: Color("gradientBackground").opacity(0.75), location: 0.5),
                    .init(color: Color("gradientBackground").opacity(1), location: 1.0)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                VStack {
                    TabView(selection: $currentPage) {
                        ForEach(OnboardingSteps.allCases) { step in
                            VStack {
                                step.page
                                HStack {
                                    if currentPage + 1 < OnboardingSteps.allCases.count {
                                        Button(action: {
                                            endOnboarding()
                                        }, label: {
                                            Text("Skip", comment: "The label for the button to exit onboarding")
                                        })
                                        .buttonStyle(SkipButton())
                                        Button(action: {
                                            currentPage += 1
                                            isFocused = true
                                        }, label: {
                                            Text("Next", comment: "The label for the to go to the next onboarding step")
                                        }).buttonStyle(NextButton())
                                    } else {
                                        Button(action: {
                                            endOnboarding()
                                        }, label: {
                                            Text("Done", comment: "The label for the button to exit onboarding")
                                        }).buttonStyle(NextButton())
                                    }
                                }.padding(.vertical)
                            }
                            .accessibilityFocused($isFocused)
                            .padding(.bottom, 32)
                            .tag(step.rawValue)
                            
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                }.frame(maxWidth: 800)
            }
        }
    }
}
