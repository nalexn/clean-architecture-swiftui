//
//  ContentViewModel.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 23.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ContentViewModel<T>: ObservableObject {

    @Published var content: Loadable<T> = .notRequested
    @Published var isLoading: Bool = false
    @Published var hasContentToDisplay: Bool = false
    @Published var shouldShowActivity: Bool = false
    @Published var shouldShowRefresh: Bool = false
    @Published var shouldShowError: Bool = false
    @Published var shouldShowContent: Bool = false
    @Published var errorString: String = ""
    
    private var cancelBag = CancelBag()

    init(publisher: AnyPublisher<Loadable<T>, Never>, hasDataToDisplay: @escaping (Loadable<T>) -> Bool) {
        cancelBag.collect {
            publisher
                .assign(to: \.content, on: self)
            $content.map(hasDataToDisplay)
                .removeDuplicates().assign(to: \.hasContentToDisplay, on: self)
            $content.map { $0.isLoading }
                .removeDuplicates().assign(to: \.isLoading, on: self)
            $isLoading.combineLatest($hasContentToDisplay).map { $0.0 && !$0.1 }
                .removeDuplicates().assign(to: \.shouldShowActivity, on: self)
            $isLoading.combineLatest($hasContentToDisplay).map { $0.0 && $0.1 }
                .removeDuplicates().assign(to: \.shouldShowRefresh, on: self)
            $content.map { $0.error != nil }
                .removeDuplicates().assign(to: \.shouldShowError, on: self)
            $content.combineLatest($shouldShowError).map { $0.0.value != nil && !$0.1 }
                .removeDuplicates().assign(to: \.shouldShowContent, on: self)
            $content.map({ resource in
                guard let error = resource.error else { return "" }
                return "An error occured: \(error.localizedDescription)"
            }).removeDuplicates().assign(to: \.errorString, on: self)
        }
    }
}
