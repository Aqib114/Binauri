//
//  HomeView.swift
//  Binauri
//
//  Created by Aqib Mehmood on 23/06/2026.
//

import SwiftUI

struct HomeView : View {
    @StateObject var viewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Night Ambience")
                        .foregroundStyle(.white)
                        .font(.title3).bold()
                    Spacer()
                    HStack(spacing: 12) {
                        CircleImageBtn(icon: "ellipsis")
                        CircleImageBtn(icon: "chevron.down")
                    }
                }
                HStack {
                    Text("seth b * 2Hz")
                        .foregroundStyle(.gray)
                    Spacer()
                    CircleImageBtn(icon: "play.fill"){
//                        viewModel.togglePlayPause()
                        
                    }
                }
                .padding(.top, 5)
                Spacer()
                ZStack {
                    Circle()
                        .fill(viewModel.isDraggingActive ? .gray.opacity(0.15) : .clear)
                        .stroke(viewModel.isDraggingActive ? Color.purple.opacity(0.5) : .clear, lineWidth: 1)
                        .frame(width: viewModel.outerRadius * 2, height: viewModel.outerRadius * 2)
                    ZStack {
                        if viewModel.isDraggingActive {
                            Image(systemName: "cone.fill")
                                .resizable()
                                .opacity(0.3)
                                .foregroundStyle(.white)
                                .frame(width: 140, height: 190)
                                .rotationEffect(.degrees(180))
                                .offset(y: -105)
                            
                            Image(systemName: "person.fill")
                                .resizable()
                                .foregroundStyle(.white)
                                .frame(width: 30, height: 30)
                           
                        } else {
                            Circle()
                                .fill(Color.purple.opacity(0.8))
                                .frame(width: 12, height: 12)
                        }
                    }
                    .position(viewModel.radarCenter)
                    if viewModel.isDraggingFromBottom && viewModel.radarGlobalFrame.contains(viewModel.dragPosition) {
                        let tempDistance = viewModel.getDistance(from: viewModel.currentDraggingLocalPoint)
                        if tempDistance <= viewModel.outerRadius {
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                                .frame(width: tempDistance * 2, height: tempDistance * 2)
                                .position(viewModel.radarCenter)
                        }
                    }
                    ForEach(viewModel.activeNodes) { node in
                        let nodeDistance = viewModel.getDistance(from: node.location)
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                .frame(width: nodeDistance * 2, height: nodeDistance * 2)
                                .position(viewModel.radarCenter)
                            VStack(spacing: 2) {
                                Image(systemName: node.imageName)
                                    .resizable()
                                    .font(.footnote)
                                    .frame(width: 20, height: 20)
                            }
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.white.opacity(0.1)))
                            .position(node.location)
                            .gesture(
                                DragGesture(coordinateSpace: .local)
                                    .onChanged { value in
                                        viewModel.isMovingRadarNode = true
                                        viewModel.updateNodeLocation(id: node.id, to: value.location)
                                    }
                                    .onEnded { value in
                                        viewModel.isMovingRadarNode = false
                                        viewModel.checkAndRemoveNode(id: node.id, finalLocation: value.location)
                                    }
                            )
                        }
                        .opacity(nodeDistance <= viewModel.outerRadius ? 1 : 0)
                    }
                }
                .frame(width: viewModel.outerRadius * 2, height: viewModel.outerRadius * 2)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { viewModel.radarGlobalFrame = geo.frame(in: .global) }
                            .onChange(of: geo.frame(in: .global)) { newValue in
                                viewModel.radarGlobalFrame = newValue
                            }
                    }
                )
                Spacer()
                HStack(spacing: 30) {
                    AddMusicButton(name: "forest", icon: "figure.mixed.cardio", onDragChanged: viewModel.handleDrag, onDragEnded: viewModel.handleDragEnd)
                    AddMusicButton(name: "pad", icon: "tornado.circle.fill", onDragChanged: viewModel.handleDrag, onDragEnded: viewModel.handleDragEnd)
                    AddMusicButton(name: "rain", icon: "fire.extinguisher.fill", onDragChanged: viewModel.handleDrag, onDragEnded: viewModel.handleDragEnd)
                    AddMusicButton(name: "stream", icon: "music.microphone", onDragChanged: viewModel.handleDrag, onDragEnded: viewModel.handleDragEnd)
                }
                .padding(.bottom, 15)
            }
            .padding()
            if viewModel.isDraggingFromBottom, let item = viewModel.currentDraggingItem {
                VStack(spacing: 4) {
                    Image(systemName: item.imageName).font(.title3)
                }
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Circle().fill(Color.white.opacity(0.1)).shadow(radius: 5))
                .position(viewModel.dragPosition)
                .ignoresSafeArea()
            }
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
        HomeView()
    }
