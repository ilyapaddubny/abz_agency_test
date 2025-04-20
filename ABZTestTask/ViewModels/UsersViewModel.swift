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

    // MARK: - Published Properties (State for the View)

    /// The array of users currently loaded and displayed. Sorted by registration date descending.
    @Published private(set) var users: [User] = []
    /// Indicates if a network request to fetch users is currently in progress.
    @Published private(set) var isLoading: Bool = false
    /// Holds an optional error message to be displayed to the user.
    @Published var errorMessage: String?
    /// Indicates if all available pages of users have been loaded.
    @Published private(set) var canLoadMorePages: Bool = true

    // MARK: - Private Properties

    /// The current page number that has been successfully loaded. Starts at 0, increments after loading page 1.
    private var currentPage: Int = 0
    /// The total number of pages available according to the last successful API response.
    private var totalPages: Int = 1
    /// A flag to prevent multiple simultaneous load requests.
    private var isFetching: Bool = false

    // MARK: - Initialization

    init() {
        // Initial fetch can be triggered from here or, more commonly,
        // from the View's .onAppear modifier via loadInitialUsers().
    }

    // MARK: - Public Methods (Actions Triggered by the View)

    /**
     Loads the initial first page of users. Resets existing user list and pagination state.
     Typically called when the view first appears.
     */
    func loadInitialUsers() async {
        // Reset state before loading the first page
        guard !isFetching else { return } // Don't reload if already fetching
        
        isFetching = true
        defer { isFetching = false } // Ensure isFetching is reset

        self.users = []
        self.currentPage = 0
        self.totalPages = 1
        self.canLoadMorePages = true
        self.errorMessage = nil
        self.isLoading = true // Show loading indicator for initial load

        await fetchUsers(page: 1)
    }

    /**
     Loads the next page of users if available and not already loading.
     Typically called when the user scrolls near the bottom of the list.
     */
    func loadMoreUsers() async {
        guard canLoadMorePages, !isFetching else {
            // Do nothing if already fetching or if all pages are loaded
            return
        }
        
        isFetching = true
        defer { isFetching = false }
        
        // isLoading is typically used for the *initial* load or full-screen refresh.
        // For pagination, often a smaller loading indicator is shown at the bottom,
        // which the View can manage based on `isFetching` or a separate @Published var if needed.
        // self.isLoading = true // Uncomment if you want full screen loading for pagination too

        await fetchUsers(page: currentPage + 1)
    }

    // MARK: - Private Helper Methods

    /**
     Performs the actual API call to fetch users for a specific page.
     Updates the ViewModel's state based on the response.

     - Parameter page: The page number to fetch.
     */
    private func fetchUsers(page: Int) async {
        // Set loading state (consider if needed for pagination)
        // if page > 1 { /* Maybe set a different loading state for pagination */ }

        do {
            let response = try await APIService.fetchUsers(page: page, count: 6) // Using count 6 per requirement

            // Process successful response
            if let fetchedUsers = response.users {
                 // If it's the first page, replace; otherwise, append.
                 if page == 1 {
                     self.users = fetchedUsers
                 } else {
                     self.users.append(contentsOf: fetchedUsers)
                 }

                // Sort the entire list by registration timestamp descending (newest first)
                // Handle potential nil timestamps (treat nil as older)
                self.users.sort { ($0.registration_timestamp ?? 0) > ($1.registration_timestamp ?? 0) }
            } else {
                // Handle case where users array is nil even on success (unlikely based on spec, but safe)
                 if page == 1 { self.users = [] }
            }

            // Update pagination info
            self.currentPage = response.page ?? page
            self.totalPages = response.total_pages ?? self.totalPages // Keep last known if missing
            self.canLoadMorePages = (response.links?.next_url != nil) && (self.currentPage < self.totalPages) // Check next_url AND page count

            self.errorMessage = nil // Clear previous errors on success

        } catch let error as APIService.APIError {
            // Handle specific API errors
            self.errorMessage = error.localizedDescription
            self.canLoadMorePages = false // Stop pagination on error
            if page == 1 { self.users = [] } // Clear users if initial load fails
            print("❌ Error fetching users (page \(page)): \(error)")
        } catch {
            // Handle unexpected errors
            self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            self.canLoadMorePages = false
             if page == 1 { self.users = [] }
            print("❌ Unexpected error fetching users (page \(page)): \(error)")
        }

        // Reset loading state after request completes (success or failure)
        self.isLoading = false
    }
}
