//
//  ImagePicker.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import SwiftUI
import UIKit

/**
 A UIViewControllerRepresentable wrapper for UIImagePickerController,
 allowing the use of the device camera within a SwiftUI view.
 */
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    let sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        // Check if the source type is available (camera might not be on simulator)
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
             picker.sourceType = sourceType
        } else {
            // Fallback or handle unavailable source - here we just default to photo library
             print("Warning: Source type \(sourceType) not available. Falling back to library.")
             picker.sourceType = .photoLibrary
        }
        // Allow editing (cropping) if desired
        // picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update needed usually
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Coordinator class to handle delegate methods
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss() // Dismiss the picker
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss() // Dismiss if cancelled
        }
    }
}
