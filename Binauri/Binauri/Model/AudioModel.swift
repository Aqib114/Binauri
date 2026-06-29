//
//  AudioModel.swift
//  Binauri
//
//  Created by Aqib Mehmood on 29/06/2026.
//

import SwiftUI

struct AudioNode: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    var location: CGPoint
}

struct DraggingItem {
    let name: String
    let imageName: String
}
