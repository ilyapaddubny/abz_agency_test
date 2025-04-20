//
//  UserCardView.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI

struct UserCardView: View {
    let user: User 
    var body: some View {
        Text("User Card for \(user.name)")
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8)
    }
}
