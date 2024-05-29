//
//  String.swift
//  EchoSwiftData
//
//  Created by Gavin Henderson on 28/05/2024.
//

import Foundation

public extension String {
    /**
     Convert a string into a slugified version
     
     For example 'This is an example' -> 'this-is-an-example
     
     Reference: https://danielsaidi.com/blog/2022/05/30/slugify-a-string
     */
    func slugified(
        separator: String = "-",
        allowedCharacters: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
    ) -> String {
        self.lowercased()
            .components(separatedBy: allowedCharacters.inverted)
            .filter { $0 != "" }
            .joined(separator: separator)
    }
}
