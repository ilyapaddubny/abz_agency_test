//
//  User.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
    let phone: String
    let position: String
    let position_id: Int
    let photo: String
    let registration_timestamp: Int?
    
    var formattedPhone: String {
        return phone.hasPrefix("+") ? phone : "+\(phone)"
    }
}