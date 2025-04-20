//
//  SignUpView.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI
import PhotosUI

/**
 Displays the user registration form.

 Allows users to input their name, email, phone, select a position,
 upload a photo, and submit the form for registration.
 Handles input validation and displays success/failure states.
 */
struct SignUpView: View {

    @StateObject private var viewModel = SignUpViewModel()
    @FocusState private var focusedField: Field?
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    @State private var showingImageSourceDialog = false
    @State private var showingPhotoPicker = false
    @State private var showingCameraPicker = false

    enum Field: Hashable { case name, email, phone }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            ScreenTitleBar(title: Constants.Strings.screenTitle)

            ScrollView {
                VStack(alignment: .leading, spacing: Constants.Layout.sectionSpacing) {
                    TextFieldsSection(
                        name: $viewModel.name,
                        email: $viewModel.email,
                        phone: $viewModel.phone,
                        validationErrors: viewModel.validationErrors,
                        focusedField: $focusedField
                    )

                    PositionSelectionSection(
                        positions: viewModel.positions,
                        selectedPositionId: $viewModel.selectedPositionId,
                        positionError: viewModel.validationErrors["position_id"]
                    )

                    PhotoUploadSection(
                        selectedImage: $viewModel.selectedPhotoUIImage,
                        photoError: viewModel.validationErrors["photo"],
                        presentImageSourceSelector: { showingImageSourceDialog = true }
                    )

                    SubmitButtonSection(
                        isLoading: viewModel.isLoading,
                        generalError: viewModel.errorMessage,
                        signUpAction: {
                            focusedField = nil
                            Task { await viewModel.registerUser() }
                        }
                    )

                }
                .padding(.horizontal, Constants.Layout.horizontalPadding)
                .padding(.vertical, Constants.Layout.formVerticalPadding)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .applyImagePickerModifiers( // Encapsulated modifiers
            viewModel: viewModel,
            selectedPhotoItem: $selectedPhotoItem,
            showingImageSourceDialog: $showingImageSourceDialog,
            showingPhotoPicker: $showingPhotoPicker,
            showingCameraPicker: $showingCameraPicker
        )
        .sheet(isPresented: .constant(viewModel.registrationSuccess != nil), onDismiss: viewModel.resetRegistrationStatus) {
            // Registration Status Modal (Keep existing placeholder or final implementation)
            RegistrationStatusModalView(viewModel: viewModel)
        }
        .onAppear {
             // Fetch positions only if needed
             if viewModel.positions.isEmpty {
                 Task { await viewModel.fetchPositions() }
             }
        }
    }
}

// MARK: - Extracted Form Sections

private extension SignUpView {

    struct TextFieldsSection: View {
        @Binding var name: String
        @Binding var email: String
        @Binding var phone: String
        let validationErrors: [String: String]
        var focusedField: FocusState<Field?>.Binding

        var body: some View {
            VStack(spacing: Constants.Layout.fieldSpacing) {
                StyledTextField(
                    label: Constants.Strings.nameLabel,
                    text: $name,
                    errorMessage: validationErrors["name"],
                    focusState: focusedField,
                    fieldCase: .name
                )
                    .textContentType(.name).submitLabel(.next)

                StyledTextField(
                    label: Constants.Strings.emailLabel,
                    text: $email,
                    keyboardType: .emailAddress,
                    autocapitalization: .none,
                    errorMessage: validationErrors["email"],
                    focusState: focusedField,
                    fieldCase: .email
                )
                    .textContentType(.emailAddress).submitLabel(.next)

                StyledTextField(
                    label: Constants.Strings.phoneLabel,
                    text: $phone,
                    prompt: Constants.Strings.phonePlaceholder,
                    keyboardType: .phonePad,
                    errorMessage: validationErrors["phone"],
                    hintText: "+38 (XXX) XXX - XX - XX",
                    focusState: focusedField,
                    fieldCase: .phone
                )
                    .textContentType(.telephoneNumber).submitLabel(.done)
            }
            .onSubmit { // Attach onSubmit here to handle focus within the section
                 switch focusedField.wrappedValue {
                 case .name: focusedField.wrappedValue = .email
                 case .email: focusedField.wrappedValue = .phone
                 default: focusedField.wrappedValue = nil
                 }
             }
        }
    }

    struct PositionSelectionSection: View {
        let positions: [Position]
        @Binding var selectedPositionId: Int?
        let positionError: String?

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text(Constants.Strings.positionSectionTitle)
                    .appTextStyle(.b1).foregroundColor(.mainText)

                ForEach(positions) { position in
                    CustomRadioButton( // This now refers to your *new* custom RadioButton struct
                        title: position.name,
                        isSelected: selectedPositionId == position.id
                    ) {
                        selectedPositionId = position.id // Action remains the same
                    }
                }
                .padding(.leading)

                if let error = positionError {
                     Text(error).appTextStyle(.b3).foregroundColor(.errorRed).padding(.top, 4)
                 }
            }
        }
    }

    struct PhotoUploadSection: View {
        @Binding var selectedImage: UIImage?
        let photoError: String?
        let presentImageSourceSelector: () -> Void

        var body: some View {
            // Assuming PhotoUploadView exists and is styled correctly
             PhotoUploadView(
                selectedImage: $selectedImage,
                errorMessage: photoError,
                presentImageSourceSelector: presentImageSourceSelector
            )
        }
    }

    struct SubmitButtonSection: View {
        let isLoading: Bool
        let generalError: String?
        let signUpAction: () -> Void

        var body: some View {
            VStack(spacing: 10) {
                Button(Constants.Strings.signUpButtonLabel, action: signUpAction)
                    .buttonStyle(PrimaryFilledButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.7 : 1.0)

                if let error = generalError {
                     Text(error)
                        .appTextStyle(.b3).foregroundColor(.errorRed)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                }
            }
        }
    }
}

// MARK: - Private Helper Views (Keep ScreenTitleBar, RadioButton)
private extension SignUpView {
    struct ScreenTitleBar: View {
        let title: String
        var body: some View {
            Text(title)
                .appTextStyle(.h1)
                .foregroundColor(.mainText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
                .background(Color.appPrimary)
        }
    }

    struct RadioButton: View {
        let title: String; let isSelected: Bool; let action: () -> Void
        var body: some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    Image(
                        systemName: isSelected ? "largecircle.fill.circle" : "circle"
                    )
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(isSelected ? .appSecondary : .secondaryText); Text(
                        title
                    )
                    .appTextStyle(.b1)
                    .foregroundColor(.mainText); Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Private ViewModifier for Image Pickers
private extension View {
    /** Encapsulates the modifiers related to presenting image pickers and dialogs. */
    @ViewBuilder
    func applyImagePickerModifiers(
        viewModel: SignUpViewModel, // Pass necessary parts of VM if needed
        selectedPhotoItem: Binding<PhotosPickerItem?>,
        showingImageSourceDialog: Binding<Bool>,
        showingPhotoPicker: Binding<Bool>,
        showingCameraPicker: Binding<Bool>
    ) -> some View {
        self
            .confirmationDialog(
                 Constants.Strings.choosePhotoTitle,
                 isPresented: showingImageSourceDialog,
                 titleVisibility: .visible
            ) {
                 Button(Constants.Strings.cameraOption) {
                     #if targetEnvironment(simulator)
                         print("Camera not available on simulator.")
                     #else
                         showingCameraPicker.wrappedValue = true
                     #endif
                 }
                 Button(Constants.Strings.galleryOption) {
                     showingPhotoPicker.wrappedValue = true
                 }
                 Button(Constants.Strings.cancelOption, role: .cancel) { }
            }
            .photosPicker(
                isPresented: showingPhotoPicker,
                selection: selectedPhotoItem,
                matching: .images
            )
            .onChange(of: selectedPhotoItem.wrappedValue) { newItem in // Attach onChange here
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        viewModel.selectedPhotoUIImage = UIImage(data: data)
                        // viewModel.validationErrors["photo"] = nil // ViewModel should handle this internally
                    } else {
                        print("Failed to load image data from PhotosPicker")
                        viewModel.selectedPhotoUIImage = nil
                    }
                }
            }
            .sheet(isPresented: showingCameraPicker) {
                 ImagePicker(selectedImage: Binding( // Create binding to VM property
                     get: { viewModel.selectedPhotoUIImage },
                     set: { viewModel.selectedPhotoUIImage = $0 }
                 ), sourceType: .camera)
                     .ignoresSafeArea()
                     // .onDisappear { // ViewModel should handle error clearing internally
                     //     if viewModel.selectedPhotoUIImage != nil {
                     //         viewModel.validationErrors["photo"] = nil
                     //     }
                     // }
            }
    }
}


// MARK: - Constants Struct
private enum Constants {
    enum Strings {
        static let screenTitle = "Working with POST request"
        static let nameLabel = "Your name"
        static let emailLabel = "Email"
        static let phoneLabel = "Phone"
        static let phonePlaceholder = "+38 (XXX) XXX - XX - XX"
        static let positionSectionTitle = "Select your position"
        static let photoSectionTitle = "Upload your photo"
        static let signUpButtonLabel = "Sign up"
        static let choosePhotoTitle = "Choose how you want to add a photo"
        static let cameraOption = "Camera"
        static let galleryOption = "Gallery"
        static let cancelOption = "Cancel"
    }
    enum Layout {
        static let sectionSpacing: CGFloat = 25
        static let fieldSpacing: CGFloat = 18 // Example spacing between text fields
        static let horizontalPadding: CGFloat = 16
        static let formVerticalPadding: CGFloat = 20
    }
}


// MARK: - Placeholder for RegistrationStatusView (Rename if needed)
private struct RegistrationStatusModalView: View { // Renamed for clarity
    @ObservedObject var viewModel: SignUpViewModel // Pass VM to access state/reset action

    var body: some View {
        // Re-implement based on mockups 0208 & 0209 later
        VStack {
            if let isSuccess = viewModel.registrationSuccess {
                Text(isSuccess ? "Success!" : "Failed!")
                    .font(.largeTitle)
                Text(isSuccess ? "User successfully registered" : (viewModel.errorMessage ?? "Registration failed"))
                    .padding()
                Button(isSuccess ? "Got it" : "Try Again") {
                    viewModel.resetRegistrationStatus()
                }
                .buttonStyle(PrimaryFilledButtonStyle())
            } else {
                 // Should ideally not be shown if viewModel.registrationSuccess is nil
                 ProgressView()
            }
        }
        .padding(40)
    }
}

// MARK: - Preview
#Preview {
    TabView {
         SignUpView()
            .tabItem { Label("Sign up", systemImage: "person.crop.circle.badge.plus") }
    }
}
