//
//  SignUpViewModel.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import Foundation
import Combine
import UIKit // Needed for UIImage

/**
 Manages the state and logic for the user registration screen (Sign Up).

 Handles form input, fetches positions, performs validation, manages photo selection,
 interacts with `APIService` to register the user, and reports success or failure states.
 */
@MainActor // Ensures @Published properties are updated on the main thread
final class SignUpViewModel: ObservableObject {

    // MARK: - Form Input Properties

    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var selectedPositionId: Int?
    @Published var selectedPhotoUIImage: UIImage? {
        didSet {
            // Convert UIImage to JPEG Data when image is selected
            updatePhotoData()
        }
    }

    // MARK: - Data Source Properties

    /// List of available positions fetched from the API.
    @Published private(set) var positions: [Position] = []

    // MARK: - State Management Properties

    /// Indicates if a network operation (fetching positions or registering user) is in progress.
    @Published private(set) var isLoading: Bool = false
    /// Holds field-specific validation error messages (Key: field name, Value: error message).
    @Published private(set) var validationErrors: [String: String] = [:] // Simplified: Store first error message per field
    /// General error message for non-validation errors (network, server logic).
    @Published var errorMessage: String?
    /// Tracks the outcome of the registration attempt (nil=idle, true=success, false=failure). Drives modal presentation.
    @Published var registrationSuccess: Bool? = nil

    // MARK: - Private Properties

    /// Holds the compressed JPEG data of the selected photo.
    private var selectedPhotoData: Data?
    /// Quality for JPEG compression (0.0 to 1.0). Adjust as needed for balance.
    private let jpegCompressionQuality: CGFloat = 0.8
    /// Maximum allowed photo file size in bytes (5 MB).
    private let maxPhotoFileSize: Int = 5 * 1024 * 1024 // 5MB

    // MARK: - Initialization

    init() {
        // Fetch positions when the ViewModel is created.
        Task {
            await fetchPositions()
        }
    }

    // MARK: - Public Methods (Actions Triggered by the View)

    /**
     Attempts to register a new user using the current form data.
     Performs validation, fetches a token, and calls the `APIService`.
     Updates `registrationSuccess`, `errorMessage`, and `validationErrors` based on the outcome.
     */
    func registerUser() async {
        // 1. Reset state
        self.errorMessage = nil
        self.validationErrors = [:]
        self.registrationSuccess = nil
        self.isLoading = true // Indicate loading starts

        // 2. Perform Client-Side Validation
        guard validateClientSide() else {
            self.isLoading = false // Stop loading if basic validation fails
            return
        }

        // 3. Ensure required data is present
        guard let positionId = selectedPositionId else {
            self.validationErrors["position_id"] = "Please select a position."
            self.isLoading = false
            return
        }
        guard let photoData = selectedPhotoData else {
            self.validationErrors["photo"] = "Please select a photo."
            self.isLoading = false
            return
        }
        // Optional: Re-check photo size here just in case
        guard photoData.count <= maxPhotoFileSize else {
             self.validationErrors["photo"] = "Photo size must not exceed 5MB."
             self.isLoading = false
             return
        }

        // 4. Perform API Registration
        do {
            // Get a fresh token *just before* registration attempt
            let token = try await APIService.getToken()

            // Call registration endpoint
            _ = try await APIService.registerUser(
                token: token,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines), // Trim whitespace
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
                positionId: positionId,
                photoData: photoData
            )

            // Success!
            self.registrationSuccess = true
            // Optionally clear the form fields on success
            // clearForm()

        } catch let error as APIService.APIError {
            // Handle specific API errors
            handleRegistrationError(error)
        } catch {
            // Handle other unexpected errors
            self.errorMessage = "An unexpected error occurred during registration: \(error.localizedDescription)"
            self.registrationSuccess = false
            print("❌ Unexpected registration error: \(error)")
        }

        // 5. Final state update
        self.isLoading = false // Indicate loading finished
    }

    /**
     Clears all form fields and validation errors.
     */
    func clearForm() {
        name = ""
        email = ""
        phone = ""
        selectedPositionId = nil
        selectedPhotoUIImage = nil
        selectedPhotoData = nil
        validationErrors = [:]
        errorMessage = nil
        registrationSuccess = nil
    }

     /**
     Resets the registration status, typically called when the success/failure modal is dismissed.
     */
    func resetRegistrationStatus() {
        self.registrationSuccess = nil
        // Keep error messages displayed until user interacts with the form again or retries
    }


    // MARK: - Private Helper Methods

    /**
     Fetches the list of available positions from the API.
     */
    func fetchPositions() async {
        self.isLoading = true // Indicate loading for positions
        self.errorMessage = nil
        do {
            let response = try await APIService.fetchPositions()
            // Ensure positions are non-nil before assigning
            self.positions = response.positions ?? []
        } catch let error as APIService.APIError {
             self.errorMessage = "Failed to load positions: \(error.localizedDescription)"
             print("❌ Error fetching positions: \(error)")
        } catch {
            self.errorMessage = "An unexpected error occurred while loading positions."
            print("❌ Unexpected error fetching positions: \(error)")
        }
         self.isLoading = false
    }

    /**
     Performs basic client-side validation on form fields. Updates `validationErrors`.
     - Returns: `true` if basic validation passes, `false` otherwise.
     */
    private func validateClientSide() -> Bool {
        var errors: [String: String] = [:]
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)

        // Name Validation (Length based on API spec)
        if trimmedName.count < 1 {
            errors["name"] = "Required field"
        }

        // Email Validation (Basic RFC-like pattern, API does stricter check)
        let emailPattern = #"^(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])$"#
        if trimmedEmail.isEmpty || trimmedEmail.range(of: emailPattern, options: .regularExpression) == nil {
             errors["email"] = "Invalid email format"
        }

        // Phone Validation (Ukrainian format +380XXXXXXXXX)
        let phonePattern = #"^[\+]{0,1}380([0-9]{9})$"#
        if trimmedPhone.isEmpty || trimmedPhone.range(of: phonePattern, options: .regularExpression) == nil {
             errors["phone"] = "Required field"
        }

        // Position Validation (Check if selected)
        var selectedPositionId: Int? {
            didSet {
                // When a position is selected (not nil), clear the corresponding validation error.
                if selectedPositionId != nil {
                    // We can modify validationErrors here because we are inside SignUpViewModel
                    validationErrors["position_id"] = nil
                }
            }
        }

        // Photo Validation (Check if selected and size)
        if selectedPhotoData == nil {
            errors["photo"] = "Please upload a photo."
        } else if let data = selectedPhotoData, data.count > maxPhotoFileSize {
             errors["photo"] = "Photo size must not exceed 5MB."
        }
        // Note: Photo dimensions (70x70) are harder to check reliably client-side without heavier image processing.
        // Rely on the API for this validation, but check file size.

        self.validationErrors = errors
        return errors.isEmpty // Valid if no errors were found
    }

    /**
     Updates the `selectedPhotoData` property by compressing the `selectedPhotoUIImage`.
     Also checks file size after compression.
     */
    private func updatePhotoData() {
        guard let image = selectedPhotoUIImage else {
            selectedPhotoData = nil
            return
        }

        // Compress the image to JPEG data
        selectedPhotoData = image.jpegData(compressionQuality: jpegCompressionQuality)

        // Check file size after compression
        if let data = selectedPhotoData, data.count > maxPhotoFileSize {
            self.validationErrors["photo"] = "Photo too large (\(data.count / 1024 / 1024)MB). Max 5MB."
            // Optionally clear the data/image if invalid size:
            // selectedPhotoData = nil
            // selectedPhotoUIImage = nil
        } else {
             // Clear photo error if size is now valid
            if validationErrors["photo"]?.contains("large") ?? false || validationErrors["photo"]?.contains("size") ?? false {
                 validationErrors["photo"] = nil
            }
        }
    }

    /**
     Handles specific API errors encountered during registration.
     Updates `errorMessage` or `validationErrors` appropriately.
     Sets `registrationSuccess` to `false`.

     - Parameter error: The `APIError` that occurred.
     */
    private func handleRegistrationError(_ error: APIService.APIError) {
        self.registrationSuccess = false // Mark as failed

        switch error {
        case .validationError(let message, let fails):
            // API returned specific field validation errors (422)
            self.errorMessage = message // General validation message
            var apiFieldErrors: [String: String] = [:]
            fails?.forEach { key, value in
                apiFieldErrors[key] = value.first ?? "Invalid input." // Take the first error message per field
            }
            // Merge API errors with any existing client-side ones (API errors take precedence)
            self.validationErrors.merge(apiFieldErrors) { (_, new) in new }
            print("❌ Registration Validation Error: \(message), Details: \(fails ?? [:])")

        case .apiLogicError(let message):
            // Specific logic errors like token expired (401) or user exists (409)
            self.errorMessage = message
            print("❌ Registration Logic Error: \(message)")

        case .tokenMissing:
             self.errorMessage = "Registration token was missing or invalid."
             print("❌ Registration Error: Token Missing")

        case .badStatusCode(let code, let message):
            self.errorMessage = message ?? "Registration failed with status code \(code)."
            print("❌ Registration Error: Status Code \(code), Message: \(message ?? "N/A")")

        default:
            // Handle other generic API errors (request failed, decoding, etc.)
            self.errorMessage = error.localizedDescription
             print("❌ Registration API Error: \(error.localizedDescription)")
        }
    }
}
