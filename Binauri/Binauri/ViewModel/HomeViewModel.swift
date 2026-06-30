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
    
    private var tempDraggingNode: AudioNode?
    private var playerNodes: [UUID: AVAudioPlayerNode] = [:]
    private var isTempAudioPlaying = false
    
    let outerRadius: CGFloat = 200
    let radarCenter = CGPoint(x: 200, y: 200)
    
    private let audioEngine = AVAudioEngine()
    private let environmentNode = AVAudioEnvironmentNode()
    
    var isDraggingActive: Bool {
        isDraggingFromBottom || isMovingRadarNode
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
        environmentNode.listenerAngularOrientation = AVAudio3DAngularOrientation(
            yaw: 0, pitch: 0, roll: 0
        )
        audioEngine.connect(environmentNode, to: audioEngine.outputNode, format: nil)
        do {
            try audioEngine.start()
        } catch {
            print("Audio Engine can't be started: \(error.localizedDescription)")
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
            print("Sound file not found: \(filename).mp3")
            return
        }
        do {
            let file = try AVAudioFile(forReading: url)
            let bufferFormat = file.processingFormat
            let bufferFrameCount = AVAudioFrameCount(file.length)
            guard let buffer = AVAudioPCMBuffer(pcmFormat: bufferFormat, frameCapacity: bufferFrameCount) else {
                print("Failed to create PCM buffer for \(filename)")
                return
            }
            try file.read(into: buffer)
            let player = AVAudioPlayerNode()
            playerNodes[node.id] = player
            audioEngine.attach(player)
            audioEngine.connect(player, to: environmentNode, format: bufferFormat)
            player.renderingAlgorithm = .sphericalHead
            player.position = convertToSpatialPosition(from: node.location)
            player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
            player.play()
            
        } catch {
            print("Audio Node load error: \(error)")
        }
    }
    func stopSpatialAudio(for node: AudioNode) {
        guard let player = playerNodes[node.id] else { return }
        player.stop()
        audioEngine.detach(player)
        playerNodes.removeValue(forKey: node.id)
    }
    func updateSpatialAudioPosition(for node: AudioNode?) {
        guard let node = node,
              let player = playerNodes[node.id] else { return }
        
        player.position = convertToSpatialPosition(from: node.location)
    }
    func handleDrag(name: String, icon: String, globalLocation: CGPoint) {
        if !isDraggingFromBottom {
            isDraggingFromBottom = true
            currentDraggingItem = DraggingItem(name: name, imageName: icon)
            tempDraggingNode = AudioNode(name: name,imageName: icon,location: currentDraggingLocalPoint)
        }
        dragPosition = globalLocation
        let localPoint = currentDraggingLocalPoint
        tempDraggingNode?.location = localPoint
        updateSpatialAudioPosition(for: tempDraggingNode)
        let insideRadar = getDistance(from: localPoint) <= outerRadius
        if insideRadar {
            if !isTempAudioPlaying, let temp = tempDraggingNode {
                playSpatialAudio(for: temp)
                isTempAudioPlaying = true
            }
        } else {
            if isTempAudioPlaying, let temp = tempDraggingNode {
                stopSpatialAudio(for: temp)
                isTempAudioPlaying = false
            }
        }
    }
    func handleDragEnd(globalLocation: CGPoint) {
        isDraggingFromBottom = false
        defer {
            tempDraggingNode = nil
            currentDraggingItem = nil
            isTempAudioPlaying = false
        }
        guard radarGlobalFrame.contains(globalLocation) else {
            if let temp = tempDraggingNode {
                stopSpatialAudio(for: temp)
            }
            return
        }
        let localPoint = currentDraggingLocalPoint
        guard getDistance(from: localPoint) <= outerRadius else {
            if let temp = tempDraggingNode {
                stopSpatialAudio(for: temp)
            }
            return
        }
        guard let item = currentDraggingItem else { return }
        if let temp = tempDraggingNode {
            stopSpatialAudio(for: temp)
        }
        let newNode = AudioNode(name: item.name,imageName: item.imageName,location: localPoint)
        activeNodes.append(newNode)
        playSpatialAudio(for: newNode)
    }
    func updateNodeLocation(id: UUID, to newLocation: CGPoint) {
        if let index = activeNodes.firstIndex(where: { $0.id == id }) {
            activeNodes[index].location = newLocation
            playerNodes[id]?.position = convertToSpatialPosition(from: newLocation)
        }
    }
    func checkAndRemoveNode(id: UUID, finalLocation: CGPoint) {
        if getDistance(from: finalLocation) > outerRadius {
            if let index = activeNodes.firstIndex(where: { $0.id == id }) {
                playerNodes[id]?.stop()
                if let player = playerNodes[id] {
                    audioEngine.detach(player)
                }
                playerNodes.removeValue(forKey: id)
                withAnimation(.easeOut(duration: 0.2)) {
                    activeNodes.remove(at: index)
                }
            }
        }
    }
}
