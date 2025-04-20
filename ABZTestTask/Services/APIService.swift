//
//  responsible.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import Foundation
import UIKit // Needed for UIImage compression

// MARK: - API Service Definition

/// A service struct responsible for handling network requests to the abz.agency test API.
/// It provides static methods for fetching users, positions, registration tokens, and registering new users.
struct APIService {

    /// The base URL for the API endpoints.
    private static let baseURL = URL(string: "https://frontend-test-assignment-api.abz.agency/api/v1")!

    // MARK: - Custom API Errors

    /// Defines specific errors that can occur during API interactions.
    enum APIError: LocalizedError {
        case invalidURL(String)
        case requestFailed(Error)
        case invalidResponse // Non-HTTP response or missing response data
        case badStatusCode(Int, String?) // HTTP status code indicates an error (e.g., 4xx, 5xx), includes optional message
        case decodingError(Error, Data? = nil) // Failed to decode JSON, includes raw data if available
        case tokenMissing // Failed to retrieve a valid token
        case apiLogicError(String) // Error reported by the API's business logic (e.g., "User not found", "Token expired")
        case validationError(message: String, fails: [String: [String]]?) // Specific 422 validation error

        var errorDescription: String? {
            switch self {
            case .invalidURL(let path):
                return "Failed to create a valid URL for path: \(path)"
            case .requestFailed(let error):
                return "Network request failed: \(error.localizedDescription)"
            case .invalidResponse:
                return "Received an invalid or missing response from the server."
            case .badStatusCode(let code, let message):
                return "Request failed with status code \(code)." + (message != nil ? " Message: \(message!)" : "")
            case .decodingError(let error, _):
                return "Failed to decode response: \(error.localizedDescription)"
            case .tokenMissing:
                return "Could not retrieve a valid registration token."
            case .apiLogicError(let message):
                return "API Error: \(message)"
            case .validationError(let message, let fails):
                var detail = "Validation Failed: \(message)"
                if let fails = fails {
                    detail += "\nDetails: \(fails)"
                }
                return detail
            }
        }
    }

    // MARK: - Helper for Decoding Error Messages

    /// Attempts to decode a generic error message structure from API error responses.
    private static func decodeErrorMessage(from data: Data) -> String? {
        let decoder = JSONDecoder()
        // Define a simple struct to capture common error message format
        struct ErrorMessageResponse: Decodable {
            let success: Bool?
            let message: String?
        }
        return try? decoder.decode(ErrorMessageResponse.self, from: data).message
    }

    // MARK: - API Methods

    /**
     Fetches a paginated list of users from the API.

     - Parameters:
       - page: The page number to retrieve (minimum 1).
       - count: The number of users to retrieve per page (default 6, max 100).
     - Throws: `APIError` if the request fails, receives an invalid response, a bad status code, or decoding fails.
     - Returns: A `UsersResponse` object containing the list of users and pagination details.
     */
    static func fetchUsers(page: Int, count: Int = 6) async throws -> UsersResponse {
        guard var components = URLComponents(url: baseURL.appendingPathComponent("users"), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL("users")
        }
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "count", value: "\(count)")
        ]
        guard let url = components.url else {
            throw APIError.invalidURL("users with query")
        }

        let request = URLRequest(url: url)
        let (data, response) = try await performRequest(request: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        switch httpResponse.statusCode {
        case 200:
            do {
                let usersResponse = try decoder.decode(UsersResponse.self, from: data)
                // Although 200 OK, the API might still return success: false (e.g., page out of bounds initially)
                // However, the spec implies 404/422 for GET errors, so we primarily rely on status code here.
                guard usersResponse.success else {
                    throw APIError.apiLogicError(usersResponse.message ?? "Failed to fetch users, but received success: false.")
                }
                return usersResponse
            } catch let decodeError {
                throw APIError.decodingError(decodeError, data)
            }
        case 404, 422:
            let message = decodeErrorMessage(from: data) ?? "Resource not found or validation failed."
            throw APIError.badStatusCode(httpResponse.statusCode, message) // Could also use apiLogicError here
        default:
             let message = decodeErrorMessage(from: data)
            throw APIError.badStatusCode(httpResponse.statusCode, message)
        }
    }

    /**
     Fetches the list of available user positions.

     - Throws: `APIError` if the request fails, receives an invalid response, a bad status code, or decoding fails.
     - Returns: A `PositionsResponse` object containing the list of positions.
     */
    static func fetchPositions() async throws -> PositionsResponse {
        let url = baseURL.appendingPathComponent("positions")
        let request = URLRequest(url: url)
        let (data, response) = try await performRequest(request: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        switch httpResponse.statusCode {
        case 200:
            do {
                let positionsResponse = try decoder.decode(PositionsResponse.self, from: data)
                guard positionsResponse.success, positionsResponse.positions != nil else {
                    throw APIError.apiLogicError(positionsResponse.message ?? "Failed to fetch positions.")
                }
                return positionsResponse
            } catch let decodeError {
                throw APIError.decodingError(decodeError, data)
            }
        default:
            let message = decodeErrorMessage(from: data)
            throw APIError.badStatusCode(httpResponse.statusCode, message)
        }
    }

    /**
     Retrieves a registration token required for registering a new user.
     Tokens are valid for 40 minutes and single-use.

     - Throws: `APIError` if the request fails, receives an invalid response, a bad status code, decoding fails, or the token is missing.
     - Returns: The registration token `String`.
     */
    static func getToken() async throws -> String {
        let url = baseURL.appendingPathComponent("token")
        let request = URLRequest(url: url)
        let (data, response) = try await performRequest(request: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        switch httpResponse.statusCode {
        case 200:
            do {
                let tokenResponse = try decoder.decode(TokenResponse.self, from: data)
                guard tokenResponse.success, let token = tokenResponse.token else {
                    throw APIError.tokenMissing // Or use apiLogicError with message if available
                }
                return token
            } catch let decodeError {
                throw APIError.decodingError(decodeError, data)
            }
        default:
            let message = decodeErrorMessage(from: data)
            throw APIError.badStatusCode(httpResponse.statusCode, message)
        }
    }

    /**
     Registers a new user with the provided details and photo.

     Requires a valid, recently obtained token. Photo must be JPEG, >= 70x70, <= 5MB.

     - Parameters:
       - token: The registration token obtained from `getToken()`.
       - name: User's name (2-60 characters).
       - email: User's email (RFC2822 format).
       - phone: User's phone number (starting with +380).
       - positionId: The ID of the user's selected position.
       - photoData: The `Data` representation of the user's photo (must be JPEG format and meet size constraints).
     - Throws: `APIError` for network issues, invalid response, bad status codes (401, 409, 422, etc.), decoding errors, or validation failures.
     - Returns: A `UserPostResponse` object indicating success or containing an error message.
     */
    static func registerUser(token: String, name: String, email: String, phone: String, positionId: Int, photoData: Data) async throws -> UserPostResponse {
        let url = baseURL.appendingPathComponent("users")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Token")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let httpBody = createMultipartBody(
            boundary: boundary,
            parameters: [
                "name": name,
                "email": email,
                "phone": phone,
                "position_id": "\(positionId)" // Ensure position ID is sent as String in multipart
            ],
            photoData: photoData,
            photoFieldName: "photo",
            photoFileName: "userPhoto.jpg" // The filename sent doesn't usually matter much for APIs
        )
        request.httpBody = httpBody

        let (data, response) = try await performRequest(request: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        do {
            switch httpResponse.statusCode {
            case 201: // Created successfully
                let postResponse = try decoder.decode(UserPostResponse.self, from: data)
                guard postResponse.success else {
                     throw APIError.apiLogicError(postResponse.message)
                }
                return postResponse
            case 401, 409: // Token expired or User exists
                let errorResponse = try? decoder.decode(UserPostResponse.self, from: data) // UserPostResponse also has success/message
                throw APIError.apiLogicError(errorResponse?.message ?? "Authorization error or conflict.")
            case 422: // Validation failed
                // Define specific structure for 422 response
                struct ValidationFailureResponse: Decodable {
                    let success: Bool
                    let message: String
                    let fails: [String: [String]]? // Dictionary of field errors
                }
                let validationResponse = try decoder.decode(ValidationFailureResponse.self, from: data)
                throw APIError.validationError(message: validationResponse.message, fails: validationResponse.fails)
            default:
                let message = decodeErrorMessage(from: data)
                throw APIError.badStatusCode(httpResponse.statusCode, message)
            }
        } catch let decodeError where !(decodeError is APIError) { // Don't re-wrap our own errors
            throw APIError.decodingError(decodeError, data)
        }
        // If an APIError was thrown inside the do block, it will propagate out correctly.
    }


    // MARK: - Private Request Helper

    /**
     Performs the actual URLSession data task.

     - Parameter request: The `URLRequest` to perform.
     - Throws: `APIError.requestFailed` if the underlying task fails.
     - Returns: A tuple containing the received `Data` and `URLResponse`.
     */
    private static func performRequest(request: URLRequest) async throws -> (Data, URLResponse) {
        do {
             print("🚀 Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
            // if let headers = request.allHTTPHeaderFields { print("   Headers: \(headers)") }
            // if let body = request.httpBody { print("   Body: \(String(data: body, encoding: .utf8) ?? "Non-UTF8 Data")") }

            let (data, response) = try await URLSession.shared.data(for: request)

             if let httpResponse = response as? HTTPURLResponse { print("✅ Response: \(httpResponse.statusCode)") }
            // print("   Data: \(String(data: data, encoding: .utf8) ?? "Non-UTF8 Data")")

            return (data, response)
        } catch {
             print("❌ Request Error: \(error)")
            throw APIError.requestFailed(error) // Wrap the underlying URLSession error
        }
    }

    // MARK: - Private Multipart Body Helper

    /**
     Creates the Data object for a multipart/form-data request body.

     - Parameters:
       - boundary: The unique boundary string for separating parts.
       - parameters: A dictionary of string key-value pairs for text fields.
       - photoData: The raw `Data` of the photo file.
       - photoFieldName: The name attribute for the file input field (e.g., "photo").
       - photoFileName: The filename to include in the Content-Disposition header.
     - Returns: The constructed `Data` object for the HTTP body.
     */
     private static func createMultipartBody(boundary: String, parameters: [String: String], photoData: Data?, photoFieldName: String, photoFileName: String) -> Data {
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        let boundarySuffix = "\r\n"

        // Append text parameters
        for (key, value) in parameters {
            body.append(Data(boundaryPrefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            body.append(Data(value.utf8))
            body.append(Data(boundarySuffix.utf8))
        }

        // Append photo data if available
        if let photoData = photoData {
            body.append(Data(boundaryPrefix.utf8))
            body.append(Data("Content-Disposition: form-data; name=\"\(photoFieldName)\"; filename=\"\(photoFileName)\"\r\n".utf8))
            body.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8)) // Assuming JPEG as required
            body.append(photoData)
            body.append(Data(boundarySuffix.utf8))
        }

        // Add final boundary
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }
}
