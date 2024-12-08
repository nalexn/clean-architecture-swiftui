//
//  ModalFlagView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 26.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI
import EnvironmentOverrides

struct ModalFlagView: View {

    let country: DBModel.Country
    @Binding var isDisplayed: Bool
    let inspection = Inspection<Self>()
    
    var body: some View {
        NavigationStack {
            country.flag.map { url in
                HStack {
                    Spacer()
                    ImageView(imageURL: url)
                        .frame(width: 300, height: 200)
                    Spacer()
                }
            }
            .navigationTitle(country.name)
            .toolbar {
                ToolbarItem {
                    closeButton
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
        .attachEnvironmentOverrides()
    }
    
    private var closeButton: some View {
        Button(action: {
            self.isDisplayed = false
        }, label: { Text("Close") })
    }
}
