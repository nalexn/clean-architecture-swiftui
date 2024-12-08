//
//  DetailRow.swift
//  CountriesSwiftUI
//
//  Created by Alexey Naumov on 25.10.2019.
//  Copyright © 2019 Alexey Naumov. All rights reserved.
//

import SwiftUI

struct DetailRow: View {
    private let leftLabel: Text
    private let rightLabel: Text
    
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

#Preview(traits: .fixedLayout(width: 375, height: 40)) {
    DetailRow(leftLabel: Text("Rate"), rightLabel: Text("$123.99"))
}
