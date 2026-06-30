//
//  AudioModel.swift
//  Binauri
//
//  Created by Aqib Mehmood on 29/06/2026.
//

import SwiftUI
import AVFoundation

struct AudioNode: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    var location: CGPoint
    let playerNode = AVAudioPlayerNode()
    var audioFile: AVAudioFile? = nil
}

struct DraggingItem {
    let name: String
    let imageName: String
}
