//
//  HomeViewModel.swift
//  Binauri
//
//  Created by Aqib Mehmood on 29/06/2026.
//

import SwiftUI

@Observable
class HomeViewModel {
    var activeNodes: [AudioNode] = [
        AudioNode(name: "Cardio", imageName: "figure.mixed.cardio", location: CGPoint(x: 130, y: 150)),
        AudioNode(name: "Music", imageName: "music.microphone", location: CGPoint(x: 270, y: 180)) ]
    var currentDraggingItem: DraggingItem? = nil
    var dragPosition: CGPoint = .zero
    var isDraggingFromBottom: Bool = false
    var radarGlobalFrame: CGRect = .zero
    let outerRadius: CGFloat = 200
    let radarCenter = CGPoint(x: 200, y: 200)
    
    func getDistance(from point: CGPoint, center: CGPoint = CGPoint(x: 200, y: 200)) -> CGFloat {
        let dx = point.x - center.x
        let dy = point.y - center.y
        return sqrt(dx * dx + dy * dy)
    }
    
    var currentDraggingLocalPoint: CGPoint {
        let localX = dragPosition.x - radarGlobalFrame.minX
        let localY = dragPosition.y - radarGlobalFrame.minY
        return CGPoint(x: localX, y: localY)
    }
    
    var isGhostInsideRadar: Bool {
        radarGlobalFrame.contains(dragPosition) && getDistance(from: currentDraggingLocalPoint) <= outerRadius
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
                }
            }
        }
        currentDraggingItem = nil
    }
    
    func updateNodeLocation(id: UUID, to newLocation: CGPoint) {
        if let index = activeNodes.firstIndex(where: { $0.id == id }) {
            activeNodes[index].location = newLocation
        }
    }
    
    func checkAndRemoveNode(id: UUID, finalLocation: CGPoint) {
        if getDistance(from: finalLocation) > outerRadius {
            withAnimation(.easeOut(duration: 0.2)) {
                activeNodes.removeAll(where: { $0.id == id })
            }
        }
    }
}
