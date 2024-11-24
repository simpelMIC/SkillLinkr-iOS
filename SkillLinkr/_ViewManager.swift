//
//  ContentView.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI

struct ContentView: View {
    enum AppStage {
        case loading
        case onboarding
        case loggedIn
    }
    
    @State var appStage: AppStage = .loading
    
    var body: some View {
        NavigationView {
            if appStage == .loading {
                LoadingView()
            } else if appStage == .onboarding {
                OnboardingManager { result in
                    if result {
                        appStage = .loggedIn
                    } else {
                        appStage = .loading
                    }
                }
            } else if appStage == .loggedIn {
                Text("Logged In")
            }
        }
        .task {
            checkAPIURL()
            checkToken()
        }
    }
    
    func checkAPIURL() {
        if DataManager().load(forKey: "apiURL") == nil {
            DataManager().save(forKey: "apiURL", value: defaultAPIURL)
        }
        print("Checked API URL. Current URL: \(DataManager().load(forKey: "apiURL") ?? "::NO URL::")")
    }
    
    func checkToken() {
        print("Checking token...")
        if SecureDataManager().loadToken() == nil {
            self.appStage = .onboarding
            print("Please login to your SkillLinkr account.")
        } else {
            self.appStage = .loggedIn
            print("Welcome back!")
        }
    }
}

struct LoadingView: View {
    var body: some View {
        Image("Logo")
            .resizable()
            .frame(width: 130, height: 130)
            .cornerRadius(30)
            .shadow(radius: 10)
            .padding()
        ProgressView()
    }
}

#Preview {
    LoadingView()
}
