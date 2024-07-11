//
//  KeyboardDetector.swift
// Echo
//
//  Created by Gavin Henderson on 04/06/2024.
//

import Foundation
import UIKit
import SwiftUI

struct KeyboardPressDetectorView: UIViewControllerRepresentable {
    typealias UIViewControllerType = KeyboardPressDetectorController

    var action: (_ press: UIPress) -> Void
    
    init(_ action: @escaping (_ press: UIPress) -> Void) {
        self.action = action
    }
    
    func makeUIViewController(context: Context) -> KeyboardPressDetectorController {
        return KeyboardPressDetectorController(action: action)
    }

    func updateUIViewController(_ uiViewController: KeyboardPressDetectorController, context: Context) {
    }
}

class KeyboardPressDetectorController: UIViewController {
    var action: (_ press: UIPress) -> Void
    
    init(action: @escaping (_ press: UIPress) -> Void) {
        self.action = action
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.action = { _ in
            print("Action not handled")
        }
        super.init(coder: coder)
    }
    
    func becomeResponder() {
        // Make sure the view can become the first responder to receive keyboard events
        self.view.isUserInteractionEnabled = true
        self.view.becomeFirstResponder()
        self.becomeFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("Become responder 0.5")
            self.view.becomeFirstResponder()
            self.becomeFirstResponder()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Become responder 1")

            self.view.becomeFirstResponder()
            self.becomeFirstResponder()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Become responder 2")

            self.view.becomeFirstResponder()
            self.becomeFirstResponder()
        }
    }
    
    override var canBecomeFirstResponder: Bool { true }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear UIViewController")
        super.viewDidAppear(animated)
        becomeResponder()
    }
    
    override func viewDidLoad() {
        print("viewDidLoad UIViewController")
        super.viewDidLoad()
        becomeResponder()
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            action(press)
        }
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            action(press)
        }
    }
}
