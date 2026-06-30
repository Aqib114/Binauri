//
//  HomeViewModel.swift
//  Binauri
//
//  Created by Aqib Mehmood on 29/06/2026.
//
import SwiftUI
import AVFoundation
internal import Combine

class HomeViewModel: ObservableObject {
    @Published var activeNodes: [AudioNode] = []
    @Published var currentDraggingItem: DraggingItem? = nil
    @Published var dragPosition: CGPoint = .zero
    @Published var isDraggingFromBottom: Bool = false
    @Published var radarGlobalFrame: CGRect = .zero
    @Published var isMovingRadarNode: Bool = false
    @Published var isPlaying = false
    
    let outerRadius: CGFloat = 200
    let radarCenter = CGPoint(x: 200, y: 200)
    
    private let audioEngine = AVAudioEngine()
    private let environmentNode = AVAudioEnvironmentNode()
    
    var isDraggingActive: Bool {
        isDraggingFromBottom || isMovingRadarNode
    }
    var isGhostInsideRadar: Bool {
        radarGlobalFrame.contains(dragPosition) && getDistance(from: currentDraggingLocalPoint) <= outerRadius
    }
    var currentDraggingLocalPoint: CGPoint {
        let localX = dragPosition.x - radarGlobalFrame.minX
        let localY = dragPosition.y - radarGlobalFrame.minY
        return CGPoint(x: localX, y: localY)
    }
    init() {
        setupSpatialAudioEngine()
    }
    private func setupSpatialAudioEngine() {
        audioEngine.attach(environmentNode)
        environmentNode.listenerPosition = AVAudio3DVector(x: 0, y: 0, z: 0)
        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(yaw: 0, pitch: 0, roll: 0)
        audioEngine.connect(environmentNode, to: audioEngine.outputNode, format: nil)
        do {
            try audioEngine.start()
        }
        catch {
            print("Audio Engine start nahi ho saka: \(error.localizedDescription)")
        }
    }
    private func convertToSpatialPosition(from localPoint: CGPoint) -> AVAudio3DVector {
        let scale: Float = 20.0
        let spatialX = Float(localPoint.x - radarCenter.x) / scale
        let spatialY = -Float(localPoint.y - radarCenter.y) / scale
        return AVAudio3DVector(x: spatialX, y: spatialY, z: 0)
    }
    func getDistance(from point: CGPoint, center: CGPoint = CGPoint(x: 200, y: 200)) -> CGFloat {
        let dx = point.x - center.x
        let dy = point.y - center.y
        return sqrt(dx * dx + dy * dy)
    }
    private func playSpatialAudio(for node: AudioNode) {
        let filename = node.name.lowercased()
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("Sound file nahi mili: \(filename).mp3")
            return
        }
        do {
            let file = try AVAudioFile(forReading: url)
            audioEngine.attach(node.playerNode)
            audioEngine.connect(node.playerNode, to: environmentNode, format: file.processingFormat)
            node.playerNode.renderingAlgorithm = .sphericalHead
            node.playerNode.position = convertToSpatialPosition(from: node.location)
            node.playerNode.scheduleFile(file, at: nil, completionHandler: nil)
            if isPlaying {
                node.playerNode.play()
            }
        }
        catch {
            print("Audio Node load error: \(error)")
        }
    }
    func togglePlayPause() {
        if isPlaying {
            activeNodes.forEach { node in
                node.playerNode.pause()
            }
        }
        else {
            activeNodes.forEach { node in
                node.playerNode.play()
            }
        }
        isPlaying.toggle()
    }
    func handleDrag(name: String, icon: String, globalLocation: CGPoint) {
        
        if !isDraggingFromBottom {
            isDraggingFromBottom = true
            currentDraggingItem = DraggingItem(name: name, imageName: icon)
        }
        dragPosition = globalLocation
    }
    func handleDragEnd(globalLocation: CGPoint) {
        isDraggingFromBottom = false
        if radarGlobalFrame.contains(globalLocation) {
            let localPoint = currentDraggingLocalPoint
            if getDistance(from: localPoint) <= outerRadius {
                if let item = currentDraggingItem {
                    let newNode = AudioNode(name: item.name, imageName: item.imageName, location: localPoint)
                    activeNodes.append(newNode)
                    playSpatialAudio(for: newNode)
                   
                    
                    
                }
            }
        }
        currentDraggingItem = nil
    }
    func updateNodeLocation(id: UUID, to newLocation: CGPoint) {
        if let index = activeNodes.firstIndex(where: { $0.id == id }) {
            activeNodes[index].location = newLocation
            let spatialPos = convertToSpatialPosition(from: newLocation)
            activeNodes[index].playerNode.position = spatialPos
        }
    }
    func checkAndRemoveNode(id: UUID, finalLocation: CGPoint) {
        if getDistance(from: finalLocation) > outerRadius {
            if let node = activeNodes.firstIndex(where: { $0.id == id }) {
                activeNodes[node].playerNode.stop()
                audioEngine.detach(activeNodes[node].playerNode)
                withAnimation(.easeOut(duration: 0.2)) {
                    _ = activeNodes.remove(at: node)
                }
                if activeNodes.isEmpty {
                    isPlaying = false
                }
            }
        }
    }
}
