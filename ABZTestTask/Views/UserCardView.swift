//
//  UserCardView.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//

import SwiftUI

struct UserCardView: View {
    let user: User
    let showDivider: Bool
    
    private enum Styling {
        static let cardHorizontalPadding: CGFloat = 16
        static let cardVerticalPadding: CGFloat = 16
        static let avatarSize: CGFloat = 50
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncUserAvatar(url: user.photo, size: Styling.avatarSize)

            VStack(alignment: .leading, spacing: 0) {
                Text(user.name)
                    .appTextStyle(.b2)
                    .foregroundColor(.mainText)
                    .lineLimit(2)
                    .padding(.bottom, 4)

                Text(user.position)
                    .appTextStyle(.b3)
                    .foregroundColor(.secondaryText)
                    .lineLimit(1)
                    .padding(.bottom, 8)

                Text(user.email)
                    .appTextStyle(.b3)
                    .foregroundColor(.mainText)
                    .lineLimit(1)
                    .truncationMode(.tail)
//                    .padding(.bottom, 2)

                Text(user.formattedPhone)
                    .appTextStyle(.b3)
                    .foregroundColor(.mainText)
                    .lineLimit(1)
                    .padding(.bottom, 24)
                if showDivider {
                    Divider()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 24)
    }
}

struct AsyncUserAvatar: View {
    let url: String?
    let size: CGFloat

    var body: some View {
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: size, height: size)
                    .background(Color.secondaryText.opacity(0.1))
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
            case .failure:
                Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.8, height: size * 0.8)
                    .padding(size * 0.1)
                    .foregroundColor(.secondaryText.opacity(0.5))
                    .frame(width: size, height: size)
                    .background(.secondaryText.opacity(0.1))
            @unknown default:
                EmptyView()
                    .frame(width: size, height: size)
                    .background(.secondaryText.opacity(0.1))
            }
        }
        .clipShape(Circle())
    }
}

#Preview {
    let sampleUser = User(
        id: 1,
        name: "Seraphina Anastasia Isolde Aurelia Celestina von Hohenzollern",
        email: "maximus_wilderman_ronaldo_schuppe@hotmail.com",
        phone: "+380982787624",
        position: "Backend developer",
        position_id: 1,
        photo: "https://frontend-test-assignment-api.abz.agency/images/users/5b977ba1245cc29.jpeg",
        registration_timestamp: 1537691099
    )
    let sampleUserNoPhoto = User(
        id: 2, name: "Malcolm Bailey", email: "jany_marazik51@hotmail.com", phone: "+380982787624",
        position: "Frontend developer", position_id: 2, photo: "invalid-url", registration_timestamp: 1537691090
    )

    VStack(spacing: 0) {
        UserCardView(user: sampleUser, showDivider: true)
        UserCardView(user: sampleUserNoPhoto, showDivider: false)
    }
    .padding() // Add overall padding for preview context
}
