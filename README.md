# ABZ Test Task - iOS Application

## Overview

This iOS application implements the ABZ.agency test assignment. The app provides a user listing with pagination and a registration form with field validation, photo upload, and API integration.

---

## Configuration Options

### API Configuration

The API base URL is configured in `APIService.swift`:

```swift
private static let baseURL = URL(string: "https://frontend-test-assignment-api.abz.agency/api/v1")!
```

### Pagination Settings

User listing pagination can be adjusted in `UsersViewModel.swift`:

```swift
private enum Config {
    static let usersPerPage: Int = 6
    static let paginationDelay: UInt64 = 500_000_000 // For demo purposes
}
```

### Photo Upload Settings

Image compression and size limits are configured in `SignUpViewModel.swift`:

```swift
private let jpegCompressionQuality: CGFloat = 0.8
private let maxPhotoFileSize: Int = 5 * 1024 * 1024 // 5MB
```

---

## Dependencies and Libraries

This project uses only **native iOS frameworks** without external dependencies:

- **SwiftUI**: For the user interface  
- **Combine**: For reactive programming patterns  
- **Network**: For connectivity monitoring  
- **PhotosUI**: For accessing the photo library  

---

## Build Instructions

### Requirements

- **Xcode 16.0 or later**
- **iOS 18.0+** deployment target
- **Swift 5.9+**

### Steps to Build

1. Clone the repository:

```bash
git clone [repository-url]
```

2. Open `ABZTestTask.xcodeproj` in Xcode  
3. Select your target device/simulator  
4. Build with `Cmd+B` or run with `Cmd+R`

---

## Running on a Physical Device

1. Connect your iOS device  
2. Select your device from the device dropdown  
3. Ensure your Apple Developer account is properly set up in Xcode  
4. Run the application with `Cmd+R`

---

## Troubleshooting

### Network Connectivity Problems

- The app requires internet connection for most features  
- When offline, the app displays the offline screen  
- Check device connectivity settings if API requests fail  

### Registration Form Validation

- Phone numbers must follow **Ukrainian format**: `+380XXXXXXXXX`  
- Email must be in **valid RFC2822** format  
- Photo must be **< 5MB** and meet minimum size requirements  

### Photo Upload Issues

- If photo upload fails, check image size and format  
- Camera access requires physical device (not available on simulator)  
- Ensure proper permissions in `Settings > Privacy > Camera/Photos`  

### Token Expiration

- Registration tokens expire after **40 minutes**  
- If you see "token expired" errors, simply retry the registration  

---

## API Documentation

The application integrates with the **ABZ.agency test API**:

- `GET /users`: Fetches paginated list of users  
- `GET /positions`: Retrieves available user positions  
- `GET /token`: Obtains registration token  
- `POST /users`: Registers new user  

The API requires **token-based authentication** for user registration, implemented in the `APIService` class.  
**API documentation**: [Swagger](https://frontend-test-assignment-api.abz.agency/api/docs)

---

## Design Implementation

The UI is implemented according to the Figma design.

---

## Code Structure

The application follows the **MVVM architecture pattern**:

### Models

- `User.swift`: User data structure  
- `Position.swift`: Position data structure  
- `UsersResponse.swift`: API response models  

### Views

- `MainTabView.swift`: Main container with tab navigation  
- `UserListView.swift`: Displays paginated user list  
- `SignUpView.swift`: Registration form implementation  
- `NoConnectionView.swift`: Offline state view  
- **UI Components**: `CustomRadioButton`, `StyledTextField`, etc.

### ViewModels

- `UsersViewModel.swift`: Manages user listing and pagination  
- `SignUpViewModel.swift`: Handles form validation and submission  
- `ConnectivityViewModel.swift`: Monitors network connectivity  

### Services

- `APIService.swift`: Handles all API interactions  
- `ConnectivityService.swift`: Monitors network state  
