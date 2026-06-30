//
//  AddMusicButton.swift
//  Binauri
//
//  Created by Aqib Mehmood on 24/06/2026.
//

import SwiftUI

struct AddMusicButton: View {
    let name: String
    let icon: String
    var imageSize: CGFloat
    var textSize: CGFloat
    var imageColor: Color
    var textColor: Color
    var onDragChanged: (String, String, CGPoint) -> Void
    var onDragEnded: (CGPoint) -> Void
    
    init(name: String, icon: String, imageSize: CGFloat = 22, textSize: CGFloat = 10, imageColor: Color = .white, textColor: Color = .gray, onDragChanged: @escaping (String, String, CGPoint) -> Void, onDragEnded: @escaping (CGPoint) -> Void) {
        self.name = name
        self.icon = icon
        self.imageSize = imageSize
        self.textSize = textSize
        self.imageColor = imageColor
        self.textColor = textColor
        self.onDragChanged = onDragChanged
        self.onDragEnded = onDragEnded
    }
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .resizable()
                .renderingMode(.template)
                .frame(width: imageSize, height: imageSize)
                .foregroundStyle(imageColor)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.white.opacity(0.1)))
            Text(name)
                .font(.system(size: textSize, weight: .regular))
                .foregroundStyle(textColor)
        }
        .gesture(
            DragGesture(minimumDistance: 10, coordinateSpace: .global)
                .onChanged { value in
                    onDragChanged(name, icon, value.location)
                }
                .onEnded { value in
                    onDragEnded(value.location)
                }
        )
    }
}
