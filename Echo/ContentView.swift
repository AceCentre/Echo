import SwiftUI
import Combine
import SharedEcho

struct ContentView: SwiftUI.View {
    @EnvironmentObject var items: ItemsList
    @EnvironmentObject var accessOptions: AccessOptions
    @EnvironmentObject var spelling: SpellingOptions
    @EnvironmentObject var analytics: Analytics
    
    @State var lastLangId: String?

    @Binding var showOnboarding: Bool
    
    @State var loading = true
    
    var body: some SwiftUI.View {
        if showOnboarding {
            Onboarding(endOnboarding: { pageNumber, finishType in
                analytics.finishedOnboarding(pageNumber: pageNumber, finishType: finishType)
            
                showOnboarding = false
            })
        } else {
            NavigationStack {
                ZStack {
                        if loading {
                            VStack {
                                ProgressView()
                                Text("Echo is loading, thank you for waiting", comment: "Text shown on loading screen.")
                            }
                        } else {
                            ZStack {
                                if accessOptions.showOnScreenArrows {
                                    OnScreenArrows(
                                        up: { items.userPrevNode() },
                                        down: { items.userNextNode() },
                                        left: { items.userBack() },
                                        right: { items.userClickHovered() }
                                    )
                                }
                                if accessOptions.enableSwitchControl {
                                    KeyPressController()
                                }
                                VStack {
                                    
                                    HStack {
                                        
                                        GeometryReader { geoReader in
                                            HStack {
                                                ForEach(items.getLevels(), id: \.self) { currentLevel in
                                                    HStack {
                                                        HStack {
                                                            if currentLevel.last {
                                                                Image(systemName: "chevron.right")
                                                            }
                                                        }.frame(minWidth: 25)
                                                        ScrollLock(selectedUUID: currentLevel.hoveredNode.id) {
                                                            ScrollView {
                                                                VStack(alignment: .leading) {
                                                                    ForEach(currentLevel.nodes) { node in
                                                                        HStack {
                                                                            if node.id == currentLevel.hoveredNode.id {
                                                                                Text(node.displayText)
                                                                                    .padding()
                                                                                    .bold()
                                                                                    .opacity(currentLevel.last ? 1 : 0.5)
                                                                                
                                                                            } else {
                                                                                Text(node.displayText)
                                                                                    .padding()
                                                                                    .opacity(currentLevel.last ? 1 : 0.5)
                                                                                
                                                                            }
                                                                        }.id(node.id)
                                                                        
                                                                    }
                                                                }.padding(.vertical, geoReader.size.height/2)
                                                                
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    }
                                    .background(Color("transparent"))
                                    .contentShape(Rectangle())
                                    .padding()
                                    .onTapGesture(count: 1, perform: {
                                        if accessOptions.allowSwipeGestures {
                                            items.userClickHovered()
                                            analytics.userInteraction(type: "Tap", extraInfo: "Single")
                                        }
                                    })
                                    // Note the directions given here refer to the direction of inertia. So 'left' is swiping your finger from right to the left
                                    .swipe(
                                        up: {
                                            if accessOptions.allowSwipeGestures {
                                                items.userNextNode()
                                                analytics.userInteraction(type: "Swipe", extraInfo: "UP")
                                            }
                                        },
                                        down: {
                                            if accessOptions.allowSwipeGestures {
                                                items.userPrevNode()
                                                analytics.userInteraction(type: "Swipe", extraInfo: "DOWN")
                                            }
                                        },
                                        left: {
                                            if accessOptions.allowSwipeGestures {
                                                items.userBack()
                                                analytics.userInteraction(type: "Swipe", extraInfo: "LEFT")
                                            }
                                        },
                                        right: {
                                            if accessOptions.allowSwipeGestures {
                                                items.userClickHovered()
                                                analytics.userInteraction(type: "Swipe", extraInfo: "RIGHT")
                                            }
                                        }
                                    )
                                    
                                    VStack {
                                        Text(items.enteredText == "" ? " " : items.enteredText)
                                            .padding(10)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .background(Color("lightGray"))
                                    .shadow(radius: 1)
                                    
                                }
                            }
                            
                            .accessibilityRepresentation(representation: {
                                Text(
                                    "Echo does not currently support system accessibility controls. To use Echo please disable your system accessibility controls. We hope to improve this in the future.",
                                    comment: "An explaination to users using Voice over about how to use Echo"
                                )
                            })
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
                .onDisappear {
                    items.onDisappear()
                }
                .onAppear {
                    loading = true
                    if let unwrappedLangId = lastLangId {
                        if unwrappedLangId != spelling.language.id {
                            items.userClear()
                            lastLangId = spelling.language.id
                        }
                    } else {
                        lastLangId = spelling.language.id
                    }
                    
                    items.onAppear()
                    loading = false
                }
            }
        }
    }
}

// periphery:ignore
struct ContentView_Previews: PreviewProvider {
    static var previews: some SwiftUI.View {
        ContentView(showOnboarding: .constant(false)).preferredColorScheme(.light)
        ContentView(showOnboarding: .constant(false)).preferredColorScheme(.dark)

    }
}
