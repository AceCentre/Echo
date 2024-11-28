//
//  ErrorHandling.swift
// Echo
//
//  Created by Gavin Henderson on 07/06/2024.
//

import Foundation
import SwiftUI

enum EchoError: LocalizedError {
    case unknown
    case noChildren
    case unhandledNodeType
    case noParent
    case noSiblings(nodeDetails: String, location: String)
    case invalidNodeIndex
    case hoveredRootNode
    case hoveredInvalidNodeType
    case noHoverNode
    case tooManySettings
    case cleanupFailed
    case failedToParseFile
    case noFileAccess
    case failedToSaveVocabFile
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Error 00: An unknown error occurred."
        case .noChildren:
            return "Error 01: Your vocabulary is empty."
        case .unhandledNodeType:
            return "Error 03: You clicked an unknown node type."
        case .noParent:
            return "Error 04: This node has no paren.t"
        case .noSiblings(let nodeDetails, let location):
            return "No siblings found. Location: \(location). Node Details: \(nodeDetails)"
        case .invalidNodeIndex:
            return "Error 06: You selected an invalid node index."
        case .hoveredRootNode:
            return "Error 07: You cannot hover the root node."
        case .hoveredInvalidNodeType:
            return "Error 08: You hovered an invalid node type."
        case .noHoverNode:
            return "Error 09: No node to hover."
        case .tooManySettings:
            return "Error 10: Too many settings initialised."
        case .cleanupFailed:
            return "Error 11: Failed to cleanup nodes."
        case .failedToParseFile:
            return "Error 12: Failed to parse imported vocabulary file."
        case .noFileAccess:
            return "Error 13: Failed to access imported vocabulary file."
        case .failedToSaveVocabFile:
            return "Error 14: Failed to save vocabulary to file"
        }
        
    }
}

struct ErrorAlert: Identifiable {
    var id = UUID()
    var message: String
    var dismissAction: (() -> Void)?
    var autoDismissTime: TimeInterval? = nil
}

class ErrorHandling: ObservableObject {
    @Published var currentAlert: ErrorAlert?
    
    func handle(error: Error) {
        print(Thread.callStackSymbols.joined(separator: "\n"))
        
        currentAlert = ErrorAlert(message: error.localizedDescription) {
            self.dismissErrorAfterDelay()
        }
    }

    private func dismissErrorAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Auto-dismiss after 5 seconds
            self.currentAlert = nil
        }
    }
}

struct ErrorView: View {
    @ObservedObject var errorHandling: ErrorHandling
    
    var body: some View {
        ZStack {}
            .alert(item: $errorHandling.currentAlert) { currentAlert in
                Alert(
                    title: Text(currentAlert.message),
                    message: Text("An error has occurred. If echo is broken please contact enquiries@acecentre.org.uk"),
                    dismissButton: .default(Text("Dismiss")) {
                        currentAlert.dismissAction?()
                    }
                )
            }
            .onAppear {
                if let autoDismissTime = errorHandling.currentAlert?.autoDismissTime {
                    DispatchQueue.main.asyncAfter(deadline: .now() + autoDismissTime) {
                        errorHandling.currentAlert = nil
                    }
                }
            }
    }
}
