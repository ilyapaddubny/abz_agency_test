//
//  StyledTextField.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI

// MARK: - Constants
private enum Constants {
    // Dimensions
    static let fieldHeight: CGFloat = 56
    static let cornerRadius: CGFloat = 4
    static let defaultBorderWidth: CGFloat = 1
    static let focusedBorderWidth: CGFloat = 2
    
    // Padding
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 14
    static let labelHorizontalPadding: CGFloat = 12
    static let labelTopPaddingWhenFloating: CGFloat = 8
    static let hintTextTopPadding: CGFloat = 4
    
    // Animation
    static let labelAnimationDuration: Double = 0.2
    
    // Offsets
    static let floatingLabelYOffset: CGFloat = -20
    static let placeholderLabelYOffset: CGFloat = 0
}

/**
 A reusable view for text input fields styled according to the app's design system.

 Includes a floating placeholder label, dynamic border color based on focus/error state,
 and displays validation error messages below the field. It integrates with an enum-based FocusState.
 */
struct StyledTextField<FieldType: Hashable>: View {
    // MARK: - Properties
    let label: String
    @Binding var text: String
    var prompt: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var isSecure: Bool = false
    var errorMessage: String?
    var hintText: String? = nil

    // --- Focus State Integration ---
    var focusState: FocusState<FieldType?>.Binding
    let fieldCase: FieldType

    // MARK: - Computed Properties
    private var isCurrentlyFocused: Bool {
        focusState.wrappedValue == fieldCase
    }

    private var shouldFloatLabel: Bool {
        isCurrentlyFocused || !text.isEmpty
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
        } else if isCurrentlyFocused {
            return .appSecondary
        } else {
            return .secondaryText
        }
    }
    
    private var borderWidth: CGFloat {
        errorMessage != nil || isCurrentlyFocused ? Constants.focusedBorderWidth : Constants.defaultBorderWidth
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.hintTextTopPadding) {
            ZStack(alignment: .leading) {
                // Animated label/placeholder
                Text(label)
                    .appTextStyle(.b3)
                    .foregroundColor(labelColor)
                    .padding(.horizontal, Constants.labelHorizontalPadding)
                    .background(shouldFloatLabel ? Color.white : Color.clear)
                    .offset(x: 4, y: shouldFloatLabel ? Constants.floatingLabelYOffset : Constants.placeholderLabelYOffset)
                    .scaleEffect(shouldFloatLabel ? 0.8 : 1, anchor: .leading)
                    .animation(.easeOut(duration: Constants.labelAnimationDuration), value: shouldFloatLabel)
                    .zIndex(1)
                
                // Text input field
                Group {
                    if isSecure {
                        SecureField("", text: $text)
                            .focused(focusState, equals: fieldCase)
                    } else {
                        TextField("", text: $text)
                            .focused(focusState, equals: fieldCase)
                    }
                }
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization == .none ? .never : nil)
                .autocorrectionDisabled(isSecure)
                .appTextStyle(.b1)
                .foregroundColor(.mainText)
                .padding(.horizontal, Constants.horizontalPadding)
                .frame(height: Constants.fieldHeight)
            }
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(Constants.cornerRadius)
            
            // Error message or hint text
            if let error = errorMessage {
                Text(error)
                    .appTextStyle(.b3)
                    .foregroundColor(.errorRed)
            } else if let hint = hintText {
                Text(hint)
                    .appTextStyle(.b3)
                    .foregroundColor(.secondaryText)
                    .padding(.leading)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        // Define the enum for the focus state
        enum Field {
            case name, email, phone
        }

        @State private var name: String = ""
        @State private var email: String = "username.gmail.com"
        @State private var phone: String = ""
        @FocusState private var focusedField: Field?

        var body: some View {
            VStack(spacing: 20) {
                StyledTextField<Field>(
                    label: "Your name",
                    text: $name,
                    keyboardType: .default,
                    errorMessage: name.isEmpty ? "Required field" : nil,
                    focusState: $focusedField,
                    fieldCase: .name
                )
                
                StyledTextField<Field>(
                    label: "Email",
                    text: $email,
                    keyboardType: .emailAddress,
                    autocapitalization: .none,
                    errorMessage: "Invalid email format",
                    focusState: $focusedField,
                    fieldCase: .email
                )
                
                StyledTextField<Field>(
                    label: "Phone",
                    text: $phone,
                    keyboardType: .phonePad,
                    errorMessage: phone.isEmpty ? "Required field" : nil,
                    hintText: "+38 (XXX) XXX - XX - XX",
                    focusState: $focusedField,
                    fieldCase: .phone
                )
            }
            .padding()
            .environment(\.colorScheme, .light)
        }
    }

    return PreviewWrapper()
}
