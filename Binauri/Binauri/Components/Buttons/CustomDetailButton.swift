//
//  CustomDetailButton.swift
//  Binauri
//
//  Created by Aqib Mehmood on 23/06/2026.
//
import SwiftUI

struct CustomDetailButton: View {
    
        let leftIcon: String
        let rightIcon: String
        let titleText: String
        let titleColor: Color
        let titleFont: Font
        let iconColor: Color
        let backgroundColor: Color
    
    init(leftIcon: String, rightIcon: String, titleText: String, titleColor: Color, titleFont: Font, iconColor: Color, backgroundColor: Color) {
        self.leftIcon = leftIcon
        self.rightIcon = rightIcon
        self.titleText = titleText
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.iconColor = iconColor
        self.backgroundColor = backgroundColor
    }
    var body: some View {
        HStack(spacing: 10){
            Image(leftIcon)
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(iconColor)
                .padding()
            Text(titleText)
                .foregroundStyle(titleColor)
                .font(titleFont)
                .padding()
            Spacer()
            Image(rightIcon)
                .renderingMode(.template)
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(iconColor)
                .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .background(backgroundColor)
    }
}

#Preview {
    VStack(spacing: 20){
        CustomDetailButton(leftIcon: "settingIcon", rightIcon: "chevronRightIcon", titleText: "Setting", titleColor: .grayLabel, titleFont: .headline, iconColor: .grayLabel, backgroundColor: .lightGrayBg)
    }
   
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .padding()
    
}
