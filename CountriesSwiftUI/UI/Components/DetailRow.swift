//
//  DetailRow.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct DetailRow: View {
    let leftLabel: Text
    let rightLabel: Text
    
    init(leftLabel: Text, rightLabel: Text) {
        self.leftLabel = leftLabel
        self.rightLabel = rightLabel
    }
    
    init(leftLabel: Text, rightLabel: LocalizedStringKey) {
        self.leftLabel = leftLabel
        self.rightLabel = Text(rightLabel)
    }
    
    var body: some View {
        HStack {
            leftLabel
                .font(.headline)
            Spacer()
            rightLabel
                .font(.callout)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
    }
}

#if DEBUG
struct DetailRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailRow(leftLabel: Text("Rate"), rightLabel: Text("$123.99"))
            .previewLayout(.fixed(width: 375, height: 40))
    }
}
#endif
