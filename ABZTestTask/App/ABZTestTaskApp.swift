//
//  ABZTestTaskApp.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI

@main
struct ABZTestTaskApp: App {
    @StateObject private var connectivityViewModel = ConnectivityViewModel()
    
    var body: some Scene {
        WindowGroup {
            if connectivityViewModel.isConnected {
                SplashView()
                    .environmentObject(connectivityViewModel)
            } else {
                NoConnectionView()
                    .environmentObject(connectivityViewModel)
            }
        }
    }
}
