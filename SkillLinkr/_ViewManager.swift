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
        VStack {
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
                AppViewManager()
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

struct ErrorView: View {
    @State var error: String
    var retry: () -> Void
    var body: some View {
        VStack {
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .foregroundStyle(.accent)
            Text("Please take a screenshot of this and send it to the developer:")
                .font(.largeTitle)
                .foregroundStyle(.accent)
            Text(error.withZeroWidthSpaces)
            HStack {
                Button("Retry") {
                    retry()
                }
                .buttonStyle(.borderedProminent)
                Button("Copy error") {
                    copyError()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
    
    func copyError() {
        UIPasteboard.general.string = error
    }
}

#Preview {
    LoadingView()
}
