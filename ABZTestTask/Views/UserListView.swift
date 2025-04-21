//
//  UserListView.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI

/**
 Displays a paginated list of users fetched from the API.

 Handles loading states (initial and pagination), empty list state, and error display.
 Allows users to scroll down to load more users.
 */
struct UserListView: View {

    // --- State Object ---
    /// The ViewModel responsible for fetching and managing user data and list state.
    @StateObject private var viewModel = UsersViewModel()

    // --- Constants ---
    private enum Strings {
        static let screenTitle = "Working with GET request"
        static let emptyListMessage = "There are no users yet"
        static let errorTitle = "Error" // For alert or prominent display
    }
    private enum Images {
        // Replace with your actual asset name for the empty state graphic
        static let emptyUsersPlaceholder = "users_empty_placeholder"
    }

    // --- Body ---
    var body: some View {
        VStack(spacing: 0) {
            // Custom Top Bar replicating navigation bar appearance
            ScreenTitleBar(title: Strings.screenTitle)

            // Main content area
            content
        }
        .background(Color.white.ignoresSafeArea()) 
        .onAppear {
            // Trigger the initial fetch when the view appears if no users are loaded yet.
            if viewModel.users.isEmpty {
                Task {
                    await viewModel.loadInitialUsers()
                }
            }
        }
    }


    /// Builds the main content view based on the current state (loading, empty, loaded, error).
    @ViewBuilder
    private var content: some View {
        ZStack {
            ScrollView {
                // LazyVStack improves performance
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.users) { user in
                        UserCardView(user: user,
                                     showDivider: user.id != viewModel.users.last?.id)
                            .padding(.horizontal, 16)
                            .onAppear {
                                if user.id == viewModel.users.last?.id && viewModel.canLoadMorePages {
                                    Task {
                                        await viewModel.loadMoreUsers()
                                    }
                                }
                            }
                    }

                    // Display pagination loading indicator at the bottom if needed
                    if viewModel.isLoading && !viewModel.users.isEmpty {
                         ProgressView()
                            .padding(.vertical)
                    }

                }
                .padding(.bottom, 20)

            }
            .opacity(viewModel.isLoading && viewModel.users.isEmpty ? 0 : 1)

            // Overlay Views (Loading, Empty, Error)
            if viewModel.isLoading && viewModel.users.isEmpty {
                ProgressView() // Centered Initial Loading indicator
            } else if viewModel.users.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                EmptyStateView() // Display when no users and not loading/error
            }

            // Display Error Message
             if let errorMessage = viewModel.errorMessage {
                 ErrorDisplayView(message: errorMessage)
             }
        }
    }

    // MARK: Reusable Subviews

    /** A simple view displaying the title centered within a colored bar. */
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

     /** A view to display when the user list is empty. */
    private struct EmptyStateView: View {
        var body: some View {
            VStack(spacing: 20) {
                Image(systemName: "person.3.sequence")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.secondaryText)

                Text(Strings.emptyListMessage)
                    .appTextStyle(.b1)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }

    /** A simple overlay to display error messages. */
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
