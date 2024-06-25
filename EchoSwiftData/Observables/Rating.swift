//
//  Rating.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 24/06/2024.
//

import Foundation
import SwiftUI
import StoreKit

class Rating: ObservableObject {
    var ratingsPromptIntervals = [10, 30, 50]
    
    @AppStorage("numberOfOpens") var numberOfOpens: Int = 0
    @AppStorage("numberOfRatingPromptsShown") var numberOfRatingPromptsShown: Int = 0
    
    func shouldShowRating() -> Bool {
        if numberOfRatingPromptsShown >= ratingsPromptIntervals.count {
            return false
        }
        
        let target = ratingsPromptIntervals[numberOfRatingPromptsShown]
                
        return numberOfOpens > target
    }
    
    func openPrompt() {
        numberOfRatingPromptsShown += 1
        guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        
        SKStoreReviewController.requestReview(in: currentScene)
    }
    
    func countOpen() {
        numberOfOpens += 1
    }
}
