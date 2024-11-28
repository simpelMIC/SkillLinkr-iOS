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
        TabView {
            NavigationStack {
                FeedView()
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Feed")
            }
            NavigationStack {
                SearchView()
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            NavigationStack {
                MessengerView()
            }
            .tabItem {
                Image(systemName: "bubble.fill")
                Text("Messages")
            }
            NavigationView {
                ProfileView(userSource: .loggedIn)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
    }
}

#Preview {
    AppViewManager()
}
