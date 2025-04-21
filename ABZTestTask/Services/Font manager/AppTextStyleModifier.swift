//
//  AppTextStyleModifier.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import SwiftUI

/// A ViewModifier that applies a specific AppTextStyle to a view.
struct AppTextStyleModifier: ViewModifier {
    let style: AppTextStyle

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing) 
    }
}

// MARK: - View Extension for Styling
extension View {
    /// Applies the predefined text style attributes (font, tracking, line spacing)
    /// from the AppTextStyle enum to the view.
    ///
    /// Example: `Text("Hello").appTextStyle(.h1)`
    ///
    /// - Parameter style: The `AppTextStyle` to apply.
    /// - Returns: A view modified with the specified text style.
    func appTextStyle(_ style: AppTextStyle) -> some View {
        self.modifier(AppTextStyleModifier(style: style))
    }
}
