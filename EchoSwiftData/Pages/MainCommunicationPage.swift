//
//  MainCommunicationPage.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 07/06/2024.
//

import Foundation
import SwiftUI

struct MainCommunicationPage: View {
    @ObservedObject var errorHandling: ErrorHandling
    
    @Environment(Settings.self) var settings: Settings
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var controllerManager: ControllerManager
    
    @StateObject var voiceController = VoiceController()
    @StateObject var mainCommunicationPageState = MainCommunicationPageState()
    @StateObject var spelling = Spelling()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if settings.showOnScreenArrows {
                    OnScreenArrows(
                        up: { mainCommunicationPageState.userPrevNode() },
                        down: { mainCommunicationPageState.userNextNode() },
                        left: { mainCommunicationPageState.userBack() },
                        right: { mainCommunicationPageState.userClickHovered() }
                    )
                }
                if settings.enableSwitchControl {
                    KeyPressController(mainCommunicationPageState: mainCommunicationPageState)
                }
                VStack {
                    NodeTreeView(mainCommunicationPageState: mainCommunicationPageState)
                        .onTapGesture(count: 1, perform: {
                            if settings.allowSwipeGestures {
                                mainCommunicationPageState.userClickHovered()
                            }
                        })
                        // Note the directions given here refer to the direction of inertia. So 'left' is swiping your finger from right to the left
                        .swipe(
                            up: {
                                if settings.allowSwipeGestures {
                                    mainCommunicationPageState.userNextNode()
                                }
                            },
                            down: {
                                if settings.allowSwipeGestures {
                                    mainCommunicationPageState.userPrevNode()
                                }
                            },
                            left: {
                                if settings.allowSwipeGestures {
                                    mainCommunicationPageState.userBack()
                                }
                            },
                            right: {
                                if settings.allowSwipeGestures {
                                    mainCommunicationPageState.userClickHovered()
                                }
                            }
                        )
                    MessageBar(mainCommunicationPageState: mainCommunicationPageState)
                }
                .onDisappear {
                    mainCommunicationPageState.onDisappear()
                }
            }
            .navigationTitle(
                String(
                    localized: "Echo: Auditory Scanning",
                    comment: "The main navigation title for the whole app"
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: {
                        SettingsPage()
                    }, label: {
                        Image(systemName: "slider.horizontal.3").foregroundColor(.blue)
                    })
                    
                }
            }
            .toolbarBackground(.visible, for: .navigationBar, .tabBar)
        }
        .onAppear {
            spelling.loadSettings(settings)
            mainCommunicationPageState.loadSettings(settings)
            voiceController.loadSettings(settings)
            
            mainCommunicationPageState.loadSpelling(spelling)
            mainCommunicationPageState.loadErrorHandling(errorHandling)
            mainCommunicationPageState.loadEngine(voiceController)
            
            controllerManager.loadMainCommunicationPageState(mainCommunicationPageState)
        }
        .onChange(of: scenePhase) {
            voiceController.setPhase(scenePhase)
        }
    }
    
}
