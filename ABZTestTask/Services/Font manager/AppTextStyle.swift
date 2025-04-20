//
//  AppTextStyle.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import SwiftUI

enum AppTextStyle {
    case h1
    case b1
    case b2
    case b3

    var font: Font {
        switch self {
        case .h1:
             // Will now use "NunitoSans-12ptExtraLight_Regular" at size 20
            return .custom(AppFonts.nunitoSansRegular, size: 20)
        case .b1:
            // Will now use "NunitoSans-12ptExtraLight_Regular" at size 16
            return .custom(AppFonts.nunitoSansRegular, size: 16)
        case .b2:
            // Will now use "NunitoSans-12ptExtraLight_Regular" at size 18
            return .custom(AppFonts.nunitoSansRegular, size: 18)
        case .b3:
            // Will now use "NunitoSans-12ptExtraLight_Regular" at size 14
            return .custom(AppFonts.nunitoSansRegular, size: 14)
        }
    }

    /// Provides the letter spacing (tracking) for the style.
    /// (Design system didn't specify, using 0 as default)
    var tracking: CGFloat {
        switch self {
        case .h1, .b1, .b2, .b3:
            return 0.0 // Adjust if your design system defines specific tracking
        }
    }

    /// Provides the line spacing *added between lines* for the style.
    /// Calculated as: Desired Line Height - Font Size
    var lineSpacing: CGFloat {
        switch self {
        case .h1:
            // Line Height: 24pt, Font Size: 20pt => Spacing = 24 - 20 = 4
            return 4
        case .b1:
            // Line Height: 24pt, Font Size: 16pt => Spacing = 24 - 16 = 8
            return 8
        case .b2:
            // Line Height: 24pt, Font Size: 18pt => Spacing = 24 - 18 = 6
            return 6
        case .b3:
            // Line Height: 20pt, Font Size: 14pt => Spacing = 20 - 14 = 6
            return 6
        }
    }

    // --- Font Sizes Defined for Calculation ---
    // (Alternatively, access directly from the Font object if reliable)
    private var fontSize: CGFloat {
         switch self {
         case .h1: return 20
         case .b1: return 16
         case .b2: return 18
         case .b3: return 14
         }
     }
}
