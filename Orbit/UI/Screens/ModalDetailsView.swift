//
//  ModalDetailsView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 26.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct ModalDetailsView: View {
    
    @ObservedObject private(set) var viewModel: ViewModel
    let inspection = Inspection<Self>()
    
    var body: some View {
        NavigationView {
            VStack {
                viewModel.country.flag.map { url in
                    HStack {
                        Spacer()
                        ImageView(viewModel: .init(container: viewModel.container, imageURL: url))
                            .frame(width: 300, height: 200)
                        Spacer()
                    }
                }
                closeButton.padding(.top, 40)
            }
            .navigationBarTitle(Text(viewModel.country.name), displayMode: .inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .attachEnvironmentOverrides()
    }
    
    private var closeButton: some View {
        Button(action: self.viewModel.close, label: { Text("Close") })
    }
}

// MARK: - ViewModel

extension ModalDetailsView {
    class ViewModel: ObservableObject {
    
        // State
        let country: Country
        var isDisplayed: Binding<Bool>
        
        // Misc
        let container: DIContainer
        private var cancelBag = CancelBag()
        
        init(container: DIContainer, country: Country, isDisplayed: Binding<Bool>) {
            self.country = country
            self.isDisplayed = isDisplayed
            self.container = container
        }
        
        // MARK: - Side Effects
        
        func close() {
            isDisplayed.wrappedValue = false
        }
    }
}

#if DEBUG
struct ModalDetailsView_Previews: PreviewProvider {
    
    @State static var isDisplayed: Bool = true
    
    static var previews: some View {
        ModalDetailsView(viewModel: .init(
            container: .preview, country: Country.mockedData[0], isDisplayed: $isDisplayed))
    }
}
#endif
