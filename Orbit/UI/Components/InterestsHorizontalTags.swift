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
            HStack(spacing: 10) {
                ForEach(interests, id: \.self) { interest in
                    Text(interest)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(
                            userVM.selectedInterests.contains(interest)
                                ? Color.blue
                                : Color.gray.opacity(0.2)
                        ).clipShape(Capsule())
                        .shadow(
                            color: userVM.selectedInterests.contains(interest)
                                ? .blue.opacity(0.5) : .clear, radius: 5, x: 0,
                            y: 4
                        )
                        .onTapGesture {
                            withAnimation(.spring()) {
                                onTapInterest(interest)
                            }
                        }
                        .scaleEffect(
                            userVM.selectedInterests.contains(interest)
                                ? 1.1 : 1.0
                        )  // Scale effect for selected interest
                        .animation(
                            .spring(),
                            value: userVM.selectedInterests.contains(interest))  // Spring animation
                }
            }
            .padding()
        }
    }
}
