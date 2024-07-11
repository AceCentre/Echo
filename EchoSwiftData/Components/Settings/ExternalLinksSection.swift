//
//  ExternalLinksSection.swift
// Echo
//
//  Created by Gavin Henderson on 25/06/2024.
//

import Foundation
import SwiftUI

struct ExternalLinksSection: View {
    var body: some View {
        if
            let docsUrl = URL(string: "https://docs.acecentre.org.uk/products/v/echo"),
            let contactUrl = URL(string: "https://acecentre.org.uk/contact"),
            let aboutUrl = URL(string: "https://acecentre.org.uk/about")
        {
            Section {
                Link(String(
                    localized: "Read Documentation",
                    comment: "A link to the external documentation"
                ), destination: docsUrl)
                Link(String(
                    localized: "Contact Us",
                    comment: "A link to the contact page"
                ), destination: contactUrl)
                Link(String(
                    localized: "About Us",
                    comment: "A link to the about page"
                ), destination: aboutUrl)
            }
        }
    }
}

struct ExternalLinksForm: View {
    var body: some View {
        VStack {
            Form {
                ExternalLinksSection()
            }
        }
    }
}
