//
//  InterestsHorizontalTags.swift
//  Orbit
//
//  Created by Rami Maalouf on 2024-10-07.
//  Copyright © 2024 CPSC 575. All rights reserved.
//
import SwiftUI

struct InterestsHorizontalTags: View {
    var interests: [String]
    @State var selectedInterests: [String] = []

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(interests, id: \.self) { interest in
                    Text(interest)
                        .padding()
                        .background(
                            selectedInterests.contains(interest)
                                ? Color.blue : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(
                            selectedInterests.contains(interest)
                                ? Color.white : Color.black
                        )
                        .clipShape(Capsule())
                        .onTapGesture {
                            toggleInterest(interest)
                        }
                }
            }
            .padding()
        }
    }

    private func toggleInterest(_ interest: String) {
        if let index = selectedInterests.firstIndex(of: interest) {
            selectedInterests.remove(at: index)
        } else {
            selectedInterests.append(interest)
        }
    }
}
