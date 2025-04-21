//
//  ABZTestTaskApp.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
//        for family in UIFont.familyNames.sorted() {
//            let names = UIFont.fontNames(forFamilyName: family)
//            print("Family: \(family) Font names: \(names)")
//        }
        return true
    }
}

@main
struct ABZTestTaskApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var connectivityViewModel = ConnectivityViewModel()
    
    @State private var showingSplash = true
    
    var body: some Scene {
        WindowGroup {
            // Group allows applying environment objects/modifiers consistently
            Group {
                // Check connectivity first
                if !connectivityViewModel.isConnected {
                    NoConnectionView()
                }
                // If connected, check if we should show the splash screen
                else if showingSplash {
                    SplashView()
                        .onAppear {
                            // Start a task to hide the splash screen after a delay
                            Task {
                                do {
                                    // Wait for 1.5 seconds (1,500,000,000 nanoseconds)
                                    try await Task.sleep(nanoseconds: 1_500_000_000)
                                    
                                    // Switch back to the main thread to update the UI state
                                    await MainActor.run {
                                        // Use animation for a smoother transition (optional)
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            self.showingSplash = false
                                        }
                                    }
                                } catch {
                                    // Handle potential cancellation if the task is cancelled
                                    print("Splash screen task cancelled.")
                                    // Force hide splash even if sleep fails/cancels
                                    await MainActor.run {
                                        self.showingSplash = false
                                    }
                                }
                            }
                        }
                }
                else {
                    MainTabView()
                }
            }
            .environmentObject(connectivityViewModel)
            .preferredColorScheme(.light)
        }
    }
}

