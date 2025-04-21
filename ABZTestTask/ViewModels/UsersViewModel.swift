//
//  UsersViewModel.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import Foundation
import Combine

/**
 Manages the state and logic for the user list screen.
 Fetches users from the `APIService` with pagination, handles loading states,
 errors, and provides the sorted list of users for the view.
 */
@MainActor // Ensures @Published properties are updated on the main thread
final class UsersViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var users: [User] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isPaginating: Bool = false
    @Published var errorMessage: String?
    @Published private(set) var canLoadMorePages: Bool = true
    
    private var currentPage: Int = 0
    private var totalPages: Int = 1
    private var isFetching: Bool = false // Prevents concurrent fetches
    
    private enum Config {
        static let usersPerPage: Int = 6
        // Delay added for the test task to demonstrate pagination loading in screencast
        static let paginationDelay: UInt64 = 500_000_000
    }

    /**
     Loads the initial first page of users. Resets existing user list and pagination state.
     */
    func loadInitialUsers() async {
            guard !isFetching else { return }

            isFetching = true
            isLoading = true
            isPaginating = false
            errorMessage = nil

            defer {
                 isFetching = false
                 isLoading = false
            }

            do {
                let response = try await APIService.fetchUsers(page: 1, count: Config.usersPerPage)

                let fetchedUsers = response.users ?? []
                self.users = fetchedUsers
                self.users.sort { ($0.registration_timestamp ?? 0) > ($1.registration_timestamp ?? 0) }

                self.currentPage = response.page ?? 1
                self.totalPages = response.total_pages ?? 1
                self.canLoadMorePages = (response.links?.next_url != nil) && (self.currentPage < self.totalPages)

            } catch let error as APIService.APIError where error.localizedDescription.contains("cancelled") {
                 print("Refresh task cancelled (ignoring).")

            } catch let error as APIService.APIError {
                self.errorMessage = error.localizedDescription
                self.canLoadMorePages = false
                self.users = []
                print("❌ Error refreshing users: \(error)")
            } catch {
                self.errorMessage = "An unexpected error occurred during refresh: \(error.localizedDescription)"
                self.canLoadMorePages = false
                self.users = []
                print("❌ Unexpected error refreshing users: \(error)")
            }
        }

        /** Loads the next page of users. */
        func loadMoreUsers() async {
            guard canLoadMorePages, !isFetching else { return }

            isFetching = true
            isPaginating = true
            
            defer {
                isFetching = false
                isPaginating = false
            }

            do {
                // Artificial delay added to demonstrate pagination loading indicator in screencast
                try await Task.sleep(nanoseconds: Config.paginationDelay)
            } catch {
                print("Pagination delay task cancelled.")
            }

            await fetchUsers(page: currentPage + 1)
        }

        /** Performs the actual API call to fetch users. */
        private func fetchUsers(page: Int) async {
            do {
                let response = try await APIService.fetchUsers(page: page, count: Config.usersPerPage)

                let fetchedUsers = response.users ?? []
                if page == 1 {
                     print("Warning: fetchUsers called directly for page 1, should use loadInitialUsers.")
                     self.users = fetchedUsers
                } else {
                     self.users.append(contentsOf: fetchedUsers)
                }

                self.users.sort { ($0.registration_timestamp ?? 0) > ($1.registration_timestamp ?? 0) }

                self.currentPage = response.page ?? page
                self.totalPages = response.total_pages ?? self.totalPages
                self.canLoadMorePages = (response.links?.next_url != nil) && (self.currentPage < self.totalPages)

            } catch let error as APIService.APIError where error.localizedDescription.contains("cancelled") {
                 print("Pagination fetch task cancelled (ignoring).")

            } catch let error as APIService.APIError {
                self.errorMessage = error.localizedDescription
                self.canLoadMorePages = false
                print("❌ Error fetching users (page \(page)): \(error)")
            } catch {
                self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                self.canLoadMorePages = false
                print("❌ Unexpected error fetching users (page \(page)): \(error)")
            }
        }
}
