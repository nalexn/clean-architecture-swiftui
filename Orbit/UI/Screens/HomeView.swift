import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel

    var body: some View {
        NavigationView {
            content
                .navigationBarItems(trailing: logoutButton)
                .navigationBarTitle("Users")
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
        } else if let error = userVM.error {
            failedView(error)
        } else {
            loadedView(userVM.filteredUsers)
        }
    }

    private var logoutButton: some View {
        Button("Logout") {
            Task {
                await authVM.logout()
            }
        }
    }

    private func failedView(_ error: String) -> some View {
        ErrorView(
            error: error as! Error,
            retryAction: {
                Task {
                    await userVM.listUsers()
                }
            }
        )
    }

    private func loadedView(_ users: [UserModel]) -> some View {
        VStack {
            SearchBar(text: $userVM.searchText)
            List(users) { user in
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                            .padding(.bottom, 1)
                        InterestsHorizontalTags(interests: user.interests ?? [])
                    }
                }
            }
        }
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
