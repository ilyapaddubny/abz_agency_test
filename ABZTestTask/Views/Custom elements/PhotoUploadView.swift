//
//  PhotoUploadView.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import SwiftUI
import PhotosUI

// MARK: - Constants
private enum Constants {
    // Strings
    static let uploadButtonText = "Upload"
    static let placeholderText = "Upload your photo"
    
    // Dimensions
    static let componentHeight: CGFloat = 56
    static let previewImageSize: CGFloat = 36
    static let cornerRadius: CGFloat = 4
    static let defaultBorderWidth: CGFloat = 1
    static let errorBorderWidth: CGFloat = 2
    
    // Padding
    static let horizontalPadding: CGFloat = 15
    static let verticalPadding: CGFloat = 14
    static let leadingTextPadding: CGFloat = 16
    static let errorTextTopPadding: CGFloat = 4
}

/**
 A view component for handling photo selection and preview.

 Displays a placeholder or the selected image preview, along with an "Upload" button.
 Integrates with PhotosPicker for selecting images from the library.
 Shows an error state based on provided validation messages.
 */
struct PhotoUploadView: View {
    @Binding var selectedImage: UIImage?
    var errorMessage: String?
    let presentImageSourceSelector: () -> Void

    // Determine border color based on error state
    private var borderColor: Color {
        errorMessage != nil ? .errorRed : .secondaryText
    }
    
    private var borderWidth: CGFloat {
        errorMessage != nil ? Constants.errorBorderWidth : Constants.defaultBorderWidth
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                // Placeholder or Image Preview
                HStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: Constants.previewImageSize, height: Constants.previewImageSize)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .padding(.leading, Constants.leadingTextPadding)
                        Spacer()
                    } else {
                        Text(Constants.placeholderText)
                            .appTextStyle(.b1)
                            .foregroundColor(.secondaryText)
                            .padding(.leading, Constants.leadingTextPadding)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: Constants.componentHeight)
                
                // Upload button on the right
                Button {
                    presentImageSourceSelector()
                } label: {
                    Text(Constants.uploadButtonText)
                        .appTextStyle(.b1)
                        .foregroundColor(.appSecondary)
                        .padding(.horizontal, Constants.horizontalPadding)
                        .padding(.vertical, Constants.verticalPadding)
                        .frame(height: Constants.componentHeight)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: Constants.cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(Constants.cornerRadius)

            // Display error message if present
            if let error = errorMessage {
                Text(error)
                    .appTextStyle(.b3)
                    .foregroundColor(.errorRed)
                    .padding(.top, Constants.errorTextTopPadding)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var image: UIImage? = nil
        @State private var item: PhotosPickerItem? = nil
        @State private var error: String? = "Photo is required"
        
        var body: some View {
            PhotoUploadView(
                selectedImage: $image,
                errorMessage: error,
                presentImageSourceSelector: { print("Selector Tapped") }
            )
            .padding()
            .onChange(of: item) { oldValue, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        image = UIImage(data: data)
                    }
                }
            }
        }
    }
    return PreviewWrapper()
}
