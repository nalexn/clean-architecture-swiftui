//
//  ModalDetailsView.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 26.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct ModalDetailsView: View {
    let country: Country
    @Binding var isDisplayed: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                country.flag.map { url in
                    HStack {
                        Spacer()
                        SVGImageView(imageURL: url)
                            .frame(width: 300, height: 200)
                        Spacer()
                    }
                }
            }
            .navigationBarTitle(Text(country.name), displayMode: .inline)
            .navigationBarItems(trailing: closeButton)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var closeButton: some View {
        Button(action: {
            self.isDisplayed = false
        }, label: { Text("Close") })
    }
}

#if DEBUG
struct ModalDetailsView_Previews: PreviewProvider {
    
    @State static var isDisplayed: Bool = true
    
    static var previews: some View {
        ModalDetailsView(country: Country.mockedData[0], isDisplayed: $isDisplayed)
            .inject(.preview)
    }
}
#endif
