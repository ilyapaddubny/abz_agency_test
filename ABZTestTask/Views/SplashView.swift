//
//  SplashView 2.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import SwiftUI

import SwiftUI

/**
 Displays the application's splash screen on launch.

 This view shows a branded background color and the primary app logo.
 It is displayed temporarily while the app initializes, controlled by the state in `ABZTestTaskApp`.
 */
struct SplashView: View {

    var body: some View {
        ZStack {
            Color.appPrimary
                .ignoresSafeArea()

            // Center the main logo vertically and horizontally.
            VStack {
                Spacer() // Pushes content towards the center vertically.

                Image("splash_screen_cat")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 106)

                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView()
}
