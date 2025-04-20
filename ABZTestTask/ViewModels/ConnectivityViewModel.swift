//
//  ConnectivityViewModel.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import Foundation
import Combine

class ConnectivityViewModel: ObservableObject {
    @Published var isConnected: Bool = true
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        ConnectivityService.shared.connectionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isConnected = isConnected
            }
            .store(in: &cancellables)
    }
}