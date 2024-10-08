//
//  SearchBar.swift
//  Orbit
//
//  Created by Alexey Naumov on 14.01.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import SwiftUI
import UIKit

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    var placeholder: String = ""  // Add a placeholder property

    func makeUIView(context: UIViewRepresentableContext<SearchBar>)
        -> UISearchBar
    {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        return searchBar
    }

    func updateUIView(
        _ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>
    ) {
        uiView.text = text
    }

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
}

extension SearchBar {
    final class Coordinator: NSObject, UISearchBarDelegate {

        private let text: Binding<String>

        init(text: Binding<String>) {
            self.text = text
        }

        func searchBar(
            _ searchBar: UISearchBar, textDidChange searchText: String
        ) {
            text.wrappedValue = searchText
        }

        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(true, animated: true)
            return true
        }

        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            searchBar.setShowsCancelButton(false, animated: true)
            return true
        }

        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.endEditing(true)
            searchBar.text = ""
            text.wrappedValue = ""
        }
    }
}
