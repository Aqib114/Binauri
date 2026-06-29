//
//  TabBar.swift
//  Binauri
//
//  Created by Aqib Mehmood on 23/06/2026.
//

import SwiftUI

struct TabBar : View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            SettingView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
#Preview {
    TabBar()
}
