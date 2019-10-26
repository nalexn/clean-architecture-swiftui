//
//  DetailRow.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct DetailRow: View {
    let leftLabel: String
    let rightLabel: String
    
    var body: some View {
        HStack {
            Text(leftLabel)
                .font(.headline)
            Spacer()
            Text(rightLabel)
                .font(.callout)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
    }
}

#if DEBUG
struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailRow(leftLabel: "Rate", rightLabel: "$123.99")
            .previewLayout(.fixed(width: 375, height: 40))
    }
}
#endif
