//
//  _AppViewManager.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI
import Foundation

struct AppViewManager: View {
    var body: some View {
        NavigationStack {
            TabView {
                VStack {
                    FeedView()
                }
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Feed")
                }
                VStack {
                    SearchView()
                }
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                VStack {
                    ProfileView()
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                VStack {
                    SettingsView()
                }
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
            }
        }
    }
}
