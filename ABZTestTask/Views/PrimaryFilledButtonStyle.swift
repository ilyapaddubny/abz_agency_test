//
//  PrimaryFilledButtonStyle.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import SwiftUI

/**
 A custom `ButtonStyle` that replicates the app's primary filled button appearance.

 This style includes:
 - A background color based on the button's state (normal, pressed, disabled).
 - Appropriate text color for each state.
 - A capsule (pill) shape.
 - The standard body text style (`.b1`) for the label.
 - A subtle scale effect on press.
 */
struct PrimaryFilledButtonStyle: ButtonStyle {
    /// Access the environment to check if the button is enabled.
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Apply the standard text style for primary buttons.
            .appTextStyle(.b1) // Assuming Body1 is appropriate, adjust if needed
            .padding(.vertical, 12) // Adjust vertical padding as needed
            .padding(.horizontal, 30) // Adjust horizontal padding as needed
            // Set text color based on enabled state.
            .foregroundColor(isEnabled ? .black : .disabledText)
            // Set background color based on enabled and pressed states.
            .background(backgroundColor(isPressed: configuration.isPressed))
            // Apply the capsule shape.
            .clipShape(Capsule())
            // Add a subtle scaling animation when pressed.
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            // Control the animation speed.
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }

    /// Helper function to determine the background color based on the button's state.
    private func backgroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return .disabledBackground
        } else if isPressed {
            return .btnPressed
        } else {
            return .appPrimary
        }
    }
}

// MARK: - Preview Helper

#Preview {
    VStack(spacing: 20) {
        Button("Enabled Button") { }
            .buttonStyle(PrimaryFilledButtonStyle())

        Button("Pressed Example") { }
            .buttonStyle(PrimaryFilledButtonStyle())
            // Simulate pressed state for preview (won't work interactively)

        Button("Disabled Button") { }
            .buttonStyle(PrimaryFilledButtonStyle())
            .disabled(true)
    }
    .padding()
}
