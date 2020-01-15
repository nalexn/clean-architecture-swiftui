//
//  SearchBar.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 14.01.2020.
//  Copyright © 2020 Alexey Naumov. All rights reserved.
//

import UIKit
import SwiftUI

struct SearchBar: UIViewRepresentable {

    @Binding var text: String
    @Binding var isEditingText: Bool

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text, isEditingText: $isEditingText)
    }
}

extension SearchBar {
    class Coordinator: NSObject, UISearchBarDelegate {
        
        let text: Binding<String>
        let isEditingText: Binding<Bool>
        
        init(text: Binding<String>, isEditingText: Binding<Bool>) {
            self.text = text
            self.isEditingText = isEditingText
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text.wrappedValue = searchText
        }
        
        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            isEditingText.wrappedValue = true
            searchBar.setShowsCancelButton(true, animated: true)
            return true
        }
        
        func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
            isEditingText.wrappedValue = false
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
