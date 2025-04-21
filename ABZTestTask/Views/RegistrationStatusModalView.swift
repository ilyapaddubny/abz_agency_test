//
//  RegistrationStatusModalView.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 21.04.2025.
//

import SwiftUI

/**
 A view presented full-screen to show the outcome (success or failure)
 of a user registration attempt, with an explicit close button.
 */
struct RegistrationStatusModalView: View {
    @ObservedObject var viewModel: SignUpViewModel
    @Environment(\.dismiss) private var dismiss

    private enum Strings {
        static let successMessage = "User successfully registered"
        static let successButton = "Got it"
        static let failureButton = "Try again"
        static let defaultFailureMessage = "Registration failed"
    }
    
    private enum Icons {
        static let success = "success_upload"
        static let failure = "failed_upload"
        static let close = "xmark"
    }
    
    private enum Layout {
        static let iconSize: CGFloat = 200
        static let spacing: CGFloat = 30
        static let contentPadding: CGFloat = 16
        static let buttonTopPadding: CGFloat = 40
        static let closeButtonPadding: CGFloat = 16
        static let closeButtonSize: CGFloat = 16
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: Layout.spacing) {
                Spacer()

                if let isSuccess = viewModel.registrationSuccess {
                    Image(isSuccess ? Icons.success : Icons.failure)
                        .resizable().scaledToFit()
                        .frame(width: Layout.iconSize, height: Layout.iconSize)

                    Text(isSuccess ? Strings.successMessage : (viewModel.errorMessage ?? Strings.defaultFailureMessage))
                        .appTextStyle(.h1)
                        .foregroundColor(.mainText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(isSuccess ? Strings.successButton : Strings.failureButton) {
                        handleButtonTap(success: isSuccess)
                    }
                    .buttonStyle(PrimaryFilledButtonStyle())

                } else {
                    ProgressView()
                    Spacer()
                    Spacer()
                }

                Spacer()
            }
            .padding(Layout.contentPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Button {
                dismiss()
            } label: {
                Image(systemName: Icons.close)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Layout.closeButtonSize, height: Layout.closeButtonSize)
                    .foregroundColor(.secondaryText)
                    .padding(8)
            }
            .padding(Layout.closeButtonPadding)
        }
    }

    private func handleButtonTap(success: Bool) {
        dismiss()
        if !success {
            Task {
                await viewModel.registerUser()
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @StateObject var successVM: SignUpViewModel = { let vm = SignUpViewModel(); vm.registrationSuccess = true; return vm }()
        @StateObject var failureVM: SignUpViewModel = { let vm = SignUpViewModel(); vm.registrationSuccess = false; vm.errorMessage = "Email exists"; return vm }()
        @State var showSuccess = false
        @State var showFailure = false

        var body: some View {
            VStack(spacing: 20) {
                Button("Show Success") { showSuccess = true }
                Button("Show Failure") { showFailure = true }
            }
            .fullScreenCover(isPresented: $showSuccess) {
                RegistrationStatusModalView(viewModel: successVM)
            }
            .fullScreenCover(isPresented: $showFailure) {
                RegistrationStatusModalView(viewModel: failureVM)
            }
        }
    }
    return PreviewWrapper()
}
