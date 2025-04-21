//
//  ConnectivityViewModel.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import Foundation
import Combine
import Network

/**
 Manages and publishes the network connectivity status of the device.

 This ViewModel subscribes to the `ConnectivityService` singleton to receive updates
 about the network path status and updates the `isConnected` property accordingly.
 Views can observe this property to react to connectivity changes.
 */
@MainActor // Ensures @Published properties are updated on the main thread
final class ConnectivityViewModel: ObservableObject {

    /// Published property indicating whether the device has an active network connection.
    /// `true` if connected (e.g., Wi-Fi or Cellular), `false` otherwise.
    @Published var isConnected: Bool = true // Start assuming connected, will update quickly

    /// Set to hold Combine subscriptions.
    private var cancellables = Set<AnyCancellable>()

    /// Initializes the ViewModel and starts observing connectivity changes.
    init() {
        // Subscribe to the connection status publisher from the shared ConnectivityService.
        ConnectivityService.shared.connectionPublisher
            .receive(on: DispatchQueue.main) // Ensure updates are received on the main thread
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
            }
            .store(in: &cancellables) // Store the subscription to keep it alive.

        self.isConnected = ConnectivityService.shared.isConnected
    }
}
