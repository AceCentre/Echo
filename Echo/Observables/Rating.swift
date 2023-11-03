//
//  Rating.swift
//  Echo
//
//  Created by Gavin Henderson on 03/11/2023.
//

import Foundation
import SwiftUI
import SharedEcho
import StoreKit

class Rating: ObservableObject {
    var ratingsPromptIntervals = [10, 30, 50]
    
    @AppStorage(StorageKeys.numberOfOpens) var numberOfOpens: Int = 0
    @AppStorage(StorageKeys.numberOfRatingPromptsShown) var numberOfRatingPromptsShown: Int = 0
    
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
