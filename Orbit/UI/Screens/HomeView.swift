import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        NavigationView {
            content
                .navigationBarItems(trailing: logoutButton)
                .navigationBarTitle("Users", displayMode: .inline)
                .background(Color(UIColor.systemGroupedBackground))
        }
        .onAppear {
            Task {
                await userVM.listUsers()
            }
        }
    }

    @ViewBuilder private var content: some View {
        if userVM.isLoading {
            ActivityIndicatorView().padding()
                .transition(.opacity)
        } else if let error = userVM.error {
            failedView(error)
                .transition(.opacity)
        } else {
            loadedView(userVM.filteredUsers)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.3))
        }
    }

    private var logoutButton: some View {
        Button(action: {
            Task {
                await authVM.logout()
            }
        }) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .foregroundColor(.red)
        }
    }

    private func failedView(_ error: String) -> some View {
        VStack {
            Text("Error loading users")
                .font(.title)
                .foregroundColor(.red)
            Text(error)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                Task {
                    await userVM.listUsers()
                }
            }) {
                Text("Retry")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    private func loadedView(_ users: [UserModel]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            SearchBar(
                text: $userVM.searchText, placeholder: "search for a user")

            // Horizontal tags for filtering by interests
            InterestsHorizontalTags(
                interests: userVM.allInterests,
                onTapInterest: { interest in
                    withAnimation {
                        userVM.toggleInterest(interest)
                    }
                }
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 3)

            // List of users
            ScrollView {
                LazyVStack(spacing: 16) {  // Using LazyVStack for efficient loading and spacing
                    ForEach(users) { user in
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(user.name)
                                    .font(.title)
                                    .padding(.bottom, 1)

                                // user-specific interests tags
                                InterestsHorizontalTags(
                                    interests: user.interests ?? [],
                                    onTapInterest: { interest in
                                        withAnimation {
                                            userVM.toggleInterest(interest)
                                        }
                                    }
                                )
                            }
//                            Spacer()  // Pushes the content to the leading edge
                        }
                        .padding()
                        .background(.ultraThinMaterial)  // Apply the translucent background effect here
                        .cornerRadius(10)
                        .shadow(radius: 3)
//                        .padding(.vertical)  // Add padding on the sides to space it from screen edges
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Preview

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AuthViewModel())
            .environmentObject(UserViewModel())
    }
}
