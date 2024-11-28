//
//  settings.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI
import Foundation

struct SettingsView: View {
    @State var user: User?
    var body: some View {
        List {
            if let user = self.user {
                Section("Your Account") {
                    NavigationLink("Edit profile") {
                        EditProfileView(user: user)
                    }
                }
            }
            Section("How you use SkillLinkr") {
                Button("Saved") {
                    
                }
                Button("Archive") {
                    
                }
                Button("Your activity") {
                    
                }
                Button("Notifications") {
                    
                }
            }
            Section("Who can see your content") {
                Button("Account privacy") {
                    
                }
                Button("Blocked") {
                    
                }
            }
            Section("How others can interact with you") {
                Button("Messages") {
                    
                }
                Button("Tags and mentions") {
                    
                }
                Button("Sharing and reuse") {
                    
                }
            }
            Section("What you see") {
                Button("Favorites") {
                    
                }
                Button ("Suggested content") {
                    
                }
            }
            Section("Your app and media") {
                Button("Device permissions") {
                    
                }
                Button("Archiving and downloading") {
                    
                }
            }
            Section("More info and support") {
                Button("Help") {
                    
                }
                Button("About") {
                    
                }
            }
            Section("Login") {
                Button("Logout", role: .destructive) {
                    
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}
