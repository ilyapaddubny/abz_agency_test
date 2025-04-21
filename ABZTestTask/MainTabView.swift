//
//  ContentView.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI

/**
 The main container view for the application, hosting the primary navigation tabs
 for user list and sign-up sections. Configures tab bar appearance.
 */
struct MainTabView: View {

    // --- Constants ---
    private enum Strings {
        static let usersTabLabel = "Users"
        static let signUpTabLabel = "Sign up"
    }
    private enum Icons {
        static let users = "person.3.sequence.fill"
        static let signUp = "person.crop.circle.badge.plus"
    }
    enum Tab {
        case users
        case signUp
    }

    // --- State ---
    @State private var selectedTab: Tab = .users

    // --- Appearance Configuration ---
    init() {
        configureTabBarAppearance()
    }

    // --- Body ---
    var body: some View {
        TabView(selection: $selectedTab) {
            UserListView()
                .tabItem {
                    Label(Strings.usersTabLabel, systemImage: Icons.users)
                }
                .tag(Tab.users)

            SignUpView()
                .tabItem {
                    Label(Strings.signUpTabLabel, systemImage: Icons.signUp)
                }
                .tag(Tab.signUp)
        }
    }

    // --- Private Helper Methods ---
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "TabBarBackground")

        // Normal (Unselected) State Appearance
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "SecondaryText")
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(named: "SecondaryText")!
        ]

        // Selected State Appearance
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "AppSecondary")!
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(named: "AppSecondary")!
        ]

        // Apply appearance globally
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
}
