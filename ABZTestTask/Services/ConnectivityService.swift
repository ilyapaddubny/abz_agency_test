//
//  ConnectivityService.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import Foundation
import Network
import Combine

class ConnectivityService {
    static let shared = ConnectivityService()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let connectionSubject = CurrentValueSubject<Bool, Never>(false)
    
    var isConnected: Bool {
        return connectionSubject.value
    }
    
    var connectionPublisher: AnyPublisher<Bool, Never> {
        return connectionSubject.eraseToAnyPublisher()
    }
    
    private init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.connectionSubject.send(path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}
