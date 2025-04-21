//
//  RadioButton.swift
//  ABZTestTask
//
//  Created by Ilya Paddubny on 20.04.2025.
//


import SwiftUI

struct CustomRadioButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    private enum Styling {
        static let outerCircleSize: CGFloat = 22
        static let borderThicknessSelected: CGFloat = 5
        static let borderThicknessNotSelected: CGFloat = 1.5
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            !isSelected ? Color.disabledText : Color.appSecondary ,
                            lineWidth: isSelected ? Styling.borderThicknessSelected : Styling.borderThicknessNotSelected
                        )
                }
                .frame(
                    width: Styling.outerCircleSize,
                    height: Styling.outerCircleSize
                )

                Text(title)
                    .appTextStyle(.b1)
                    .foregroundColor(.mainText)

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 15) {
        CustomRadioButton(title: "Option 1", isSelected: true) {
            print("Option 1 Tapped")
        }
        CustomRadioButton(title: "Option 2", isSelected: false) {
            print("Option 2 Tapped")
        }
        CustomRadioButton(title: "Option 3 - A Longer Label", isSelected: false) {
            print("Option 3 Tapped")
        }
    }
    .padding()
    .environment(\.colorScheme, .light)
}
