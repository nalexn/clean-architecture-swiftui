//
//  CountryCell.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct CountryCell: View {
    let country: Country
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(country.name)
                .font(.title)
            Text("Population \(country.population)")
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
    }
}

#if DEBUG
struct CountryCell_Previews: PreviewProvider {
    static var previews: some View {
        CountryCell(country: Country.mockedData[0])
            .previewLayout(.fixed(width: 375, height: 60))
    }
}
#endif
