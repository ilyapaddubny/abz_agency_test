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
