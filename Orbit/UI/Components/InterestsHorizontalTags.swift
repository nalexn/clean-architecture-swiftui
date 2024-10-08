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
    var onTapInterest: (String) -> Void
    @EnvironmentObject var userVM: UserViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(interests, id: \.self) { interest in
                    Text(interest)
                        .padding()
                        .background(
                            userVM.selectedInterests.contains(interest)
                                ? Color.blue : Color.gray.opacity(0.2)
                        )
                        .foregroundColor(
                            userVM.selectedInterests.contains(interest)
                                ? Color.white : Color.black
                        )
                        .clipShape(Capsule())
                        .onTapGesture {
                            onTapInterest(interest)
                        }
                }
            }
            .padding()
        }
    }
}
