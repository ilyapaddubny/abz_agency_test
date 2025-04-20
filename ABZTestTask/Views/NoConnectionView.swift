//
//  NoConnectionView.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI

/**
 Displays a screen informing the user that there is no active internet connection.

 Includes an icon, an informative message, and a button to acknowledge,
 allowing the app's automatic connectivity check to potentially proceed when connection returns.
 */
struct NoConnectionView: View {

    private enum Strings {
        static let noConnectionMessage = "There is no internet connection"
        static let tryAgainButtonLabel = "Try again"
    }

    private let noConnectionIconName = "no_connection_icon"

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Image(noConnectionIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)

            Text(Strings.noConnectionMessage)
                .appTextStyle(.h1)
                .foregroundColor(.mainText)
                .multilineTextAlignment(.center)

            // MARK: - Try Again Button
            Button(Strings.tryAgainButtonLabel) {
                 print("Try Again button tapped.")
            }
            .buttonStyle(PrimaryFilledButtonStyle())

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}


#Preview {
    NoConnectionView()
}
