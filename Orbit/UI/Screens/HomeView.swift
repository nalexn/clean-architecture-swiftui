import AppwriteModels
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var userVM: UserViewModel
    @EnvironmentObject private var authVM: AuthViewModel
    @FocusState private var focusedTextField: FormTextField?
    @State private var searchText: String = ""
    @State private var usersState: Loadable<[UserModel]> = .notRequested

    enum FormTextField {
        case title, description
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                content
                    .navigationBarItems(trailing: self.logoutButton)
                    .navigationBarTitle("Users")
                //                    .navigationBarHidden(UsersSearch.keyboardHeight > 0)
                //                    .animation(.easeOut, value: self.userVM.keyboardHeight)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .onAppear {
            loadUsers()
        }
    }

    @ViewBuilder private var content: some View {
        switch usersState {
        case .notRequested:
            notRequestedView
        case let .isLoading(last, _):
            loadingView(last)
        case let .loaded(users):
            loadedView(users)
        case let .failed(error):
            failedView(error)
        }
    }

    private var logoutButton: some View {
        Button("Logout") {
            Task {
                await authVM.logout()
            }
        }
    }

    private func loadUsers() {
        usersState = .isLoading(last: nil, cancelBag: CancelBag())
        Task {
            guard let users = await userVM.listUsers() else {

                usersState = .failed(userVM.error as! Error)
                return
            }
            usersState = .loaded(users)
        }
    }
}

// MARK: - Loading Content

extension HomeView {
    private var notRequestedView: some View {
        Text("").onAppear(perform: loadUsers)
    }

    private func loadingView(_ previouslyLoaded: [UserModel]?) -> some View {
        if let users = previouslyLoaded {
            return AnyView(loadedView(users))
        } else {
            return AnyView(ActivityIndicatorView().padding())
        }
    }

    private func failedView(_ error: Error) -> some View {
        ErrorView(
            error: error,
            retryAction: { loadUsers() }
        )
    }
}

// MARK: - Displaying Content

extension HomeView {
    //    struct UsersSearch {
    //        var searchText: String = ""
    //        var keyboardHeight: CGFloat = 0
    //        var locale: Locale = .backendDefault
    //    }
    private func loadedView(_ users: [UserModel]) -> some View {
        VStack {
            SearchBar(text: $searchText)
            List(filteredUsers(users)) { user in
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.largeTitle)
                            .padding(.bottom, 1)

                        InterestsHorizontalTags(interests: user.interests ?? [])
                    }
                }
            }
        }
    }

    private func filteredUsers(_ users: [UserModel]) -> [UserModel] {
        if searchText.isEmpty {
            return users
        } else {
            return users.filter { user in
                user.name.lowercased().contains(searchText.lowercased())
                    || (user.interests?.joined(separator: " ").lowercased()
                        .contains(searchText.lowercased()) ?? false)
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
