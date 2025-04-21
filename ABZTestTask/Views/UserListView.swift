//
//  UserListView.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI

/**
 Displays a paginated list of users fetched from the API.
 Handles loading states, empty list state, and error display.
 */
struct UserListView: View {
    @StateObject private var viewModel = UsersViewModel()

    private enum Strings {
        static let screenTitle = "Working with GET request"
        static let emptyListMessage = "There are no users yet"
        static let errorTitle = "Error"
    }
    
    private enum Images {
        static let emptyUsersPlaceholder = "users_empty_placeholder"
    }

    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: Strings.screenTitle)
            content
        }
        .background(Color.white.ignoresSafeArea())
//        .onAppear {
//            Task {
//                await viewModel.loadInitialUsers()
//            }
//        }
    }

    @ViewBuilder
    private var content: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.users) { user in
                        UserCardView(
                            user: user,
                            showDivider: user.id != viewModel.users.last?.id
                        )
                        .padding(.horizontal, 16)
                        .onAppear {
                            // Trigger pagination when last item appears
                            if user.id == viewModel.users.last?.id
                                && viewModel.canLoadMorePages
                                && !viewModel.isPaginating {
                                Task {
                                    await viewModel.loadMoreUsers()
                                }
                            }
                        }
                    }

                    if viewModel.isPaginating {
                         ProgressView()
                            .padding(.vertical)
                    }
                }
                .padding(.bottom, 20)
            }
            .refreshable {
                await viewModel.loadInitialUsers()
            }
            .opacity(viewModel.isLoading && viewModel.users.isEmpty ? 0 : 1)

            if viewModel.isLoading && viewModel.users.isEmpty {
                ProgressView()
            }
            else if viewModel.users.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                EmptyStateView()
            }

             if let errorMessage = viewModel.errorMessage {
                 ErrorDisplayView(message: errorMessage)
             }
        }
    }

    // MARK: Reusable Subviews

    private struct ScreenTitleBar: View {
        let title: String
        var body: some View {
            Text(title)
                .appTextStyle(.h1)
                .foregroundColor(.mainText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
                .background(Color.appPrimary)
        }
    }

    private struct EmptyStateView: View {
        var body: some View {
            VStack(spacing: 20) {
                Image(Images.emptyUsersPlaceholder)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text(Strings.emptyListMessage)
                    .appTextStyle(.h1)
                    .foregroundColor(.mainText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    private struct ErrorDisplayView: View {
         let message: String
         var body: some View {
             VStack {
                 Spacer()
                 Text(message)
                     .padding()
                     .frame(maxWidth: .infinity)
                     .background(.ultraThinMaterial)
                     .foregroundColor(.red)
                     .cornerRadius(8)
                     .padding()
                 Spacer()
             }
             .background(Color.black.opacity(0.1))
         }
     }
}

// MARK: - Preview
#Preview {
     TabView {
         NavigationView {
             UserListView()
         }
         .tabItem { Label("Users", systemImage: "person.3.sequence.fill") }
     }
}
