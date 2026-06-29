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
    var imageSize: CGFloat = 22
    var textSize: CGFloat = 10
    var imageColor: Color = .white
    var textColor: Color = .gray
    var onDragChanged: (String, String, CGPoint) -> Void
    var onDragEnded: (CGPoint) -> Void
    
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
