//
//  Onboarding.swift
//  Echo
//
//  Created by Gavin Henderson on 26/10/2023.
//

import Foundation
import SwiftUI

enum OnboardingSteps: Int, CaseIterable, Identifiable {
    case introVideo = 0
    case secondStep = 1
    case cueVoice =  2
    case speakingVoice = 3
    case scanning = 4
    case prediction = 5
    case onScreenArrows = 6
    case swipeOnboarding = 7
    case switchOnboarding = 8
    case analytics = 9

    var id: String {
        switch self {
        case .introVideo: "intro"
        case .secondStep: "second"
        case .onScreenArrows: "arrows"
        case .swipeOnboarding: "swipe"
        case .cueVoice: "cueVoice"
        case .speakingVoice: "speakingVoice"
        case .analytics: "analytics"
        case .prediction: "prediction"
        case .switchOnboarding: "switch"
        case .scanning: "Scanning"
        }
    }
    
    @ViewBuilder var page: some View {
        switch self {
        case .introVideo: IntroStep()
        case .secondStep: SecondStep()
        case .onScreenArrows: OnScreenArrowsOnboarding()
        case .swipeOnboarding: SwipeOnboarding()
        case .cueVoice: CueVoiceOnboarding()
        case .speakingVoice: SpeakingVoiceOnboarding()
        case .analytics: AnalyticsOnboarding()
        case .prediction: PredictionOnboarding()
        case .switchOnboarding: SwitchOnboarding()
        case .scanning: ScanningOnboarding()
        }
    }
}

struct OnboardingSettingsPage: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        Onboarding(endOnboarding: { _, _ in
            self.presentationMode.wrappedValue.dismiss()
        })
    }
}

struct Onboarding: View {
    @State var currentPage: Int = 0
    @AccessibilityFocusState var isFocused: Bool
    var endOnboarding: (_ pageNumber: Int, _ finishType: String) -> Void
    
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
                                            endOnboarding(currentPage, "skip")
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
                                            endOnboarding(currentPage, "completed")
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

struct OnboardingWrapper: View {
    @StateObject var access: AccessOptions = AccessOptions()
    @StateObject var voiceEngine: VoiceController = VoiceController()
    @StateObject var analytics: Analytics = Analytics()
    @StateObject var spelling: SpellingOptions = SpellingOptions()
    @StateObject var scanning: ScanningOptions = ScanningOptions()
    
    var body: some View {
        ZStack {
            Onboarding(endOnboarding: { _, _ in
                print("Done")
            })
        }
        .environmentObject(access)
        .environmentObject(voiceEngine)
        .environmentObject(analytics)
        .environmentObject(spelling)
        .environmentObject(scanning)
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        OnboardingWrapper()
            .preferredColorScheme(.light)
        OnboardingWrapper()
            .preferredColorScheme(.dark)
    }
}
