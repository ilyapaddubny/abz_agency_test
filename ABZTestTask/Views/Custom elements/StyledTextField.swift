//
//  StyledTextField.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import SwiftUI

/**
 A reusable view for text input fields styled according to the app's design system.

 Includes a floating placeholder label, dynamic border color based on focus/error state,
 and displays validation error messages below the field. It integrates with an enum-based FocusState.
 */
struct StyledTextField<FieldType: Hashable>: View { // Make it generic for the FocusState type
    let label: String
    @Binding var text: String
    var prompt: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var isSecure: Bool = false
    var errorMessage: String?

    // --- Focus State Integration ---
    /// The binding to the parent view's focus state enum.
    var focusState: FocusState<FieldType?>.Binding // Changed: Takes the parent's binding
    /// The specific enum case this text field represents.
    let fieldCase: FieldType // Added: Knows its own case

    // Determine colors based on state
    private var isCurrentlyFocused: Bool {
        focusState.wrappedValue == fieldCase // Check if the parent's state matches this field's case
    }

    private var borderColor: Color {
        if errorMessage != nil {
            return .errorRed
        } else if isCurrentlyFocused {
            return .appSecondary
        } else {
            return .secondaryText
        }
    }

    private var labelColor: Color {
        if errorMessage != nil {
            return .errorRed
        } else if isCurrentlyFocused { // Use the calculated boolean
            return .appSecondary
        } else {
            return .secondaryText
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .appTextStyle(.b3)
                .foregroundColor(labelColor)
                .padding(.horizontal, 12)
                .offset(y: 8)
                .zIndex(1)

            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .focused(focusState, equals: fieldCase) // Apply focused modifier correctly
                } else {
                    TextField("", text: $text, prompt: prompt != nil ? Text(prompt!).foregroundColor(.secondaryText) : nil)
                        .focused(focusState, equals: fieldCase) // Apply focused modifier correctly
                }
            }
            .keyboardType(keyboardType)
            .textInputAutocapitalization(autocapitalization == .none ? .never : nil)
            .autocorrectionDisabled(isSecure)
            .appTextStyle(.b1)
            .foregroundColor(.mainText)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor, lineWidth: errorMessage != nil || isCurrentlyFocused ? 2 : 1) // Use calculated boolean
            )
            .cornerRadius(4)
            // .focused($isFocused) // REMOVED: .focused modifier applied directly to TextField/SecureField above

            if let error = errorMessage {
                Text(error)
                    .appTextStyle(.b3)
                    .foregroundColor(.errorRed)
                    .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        // Define the enum for the focus state
        enum Field {
            case email
        }

        @State private var email: String = ""
        @FocusState private var focusedField: Field?

        var body: some View {
            VStack {
                StyledTextField<Field>(
                    label: "Email",
                    text: $email,
                    prompt: "Enter your email",
                    keyboardType: .emailAddress,
                    errorMessage: email.isEmpty ? "Email is required" : nil,
                    focusState: $focusedField,
                    fieldCase: .email
                )
                .padding()
            }
            .padding()
            .environment(\.colorScheme, .light)
        }
    }

    return PreviewWrapper()
}
