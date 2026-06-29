//
//  CircleImageBtn.swift
//  Binauri
//
//  Created by Aqib Mehmood on 29/06/2026.
//
import SwiftUI

struct CircleImageBtn: View {
    let icon: String
    var body: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.15))
                .frame(width: 38, height: 38)
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.footnote)
        }
    }
}
