//
//  UsersResponse.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import Foundation

struct UsersResponse: Codable {
    let success: Bool
    let page: Int?
    let total_pages: Int?
    let total_users: Int?
    let count: Int?
    let links: Links?
    let users: [User]?
    let message: String?
}

struct Links: Codable {
    let next_url: String?
    let prev_url: String?
}

struct PositionsResponse: Codable {
    let success: Bool
    let positions: [Position]?
    let message: String?
}

struct TokenResponse: Codable {
    let success: Bool
    let token: String?
    let message: String?
}

struct UserPostResponse: Codable {
    let success: Bool
    let user_id: Int?
    let message: String
}
