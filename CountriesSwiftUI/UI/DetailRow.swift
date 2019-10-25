//
//  DetailRow.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.callout)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 44, alignment: .leading)
    }
}

#if DEBUG
struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailRow(title: "Rate", value: "$123.99")
            .previewLayout(.fixed(width: 375, height: 44))
    }
}
#endif
