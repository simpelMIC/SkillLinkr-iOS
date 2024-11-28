//
//  profile.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI
import Foundation

struct ProfileView: View {
    enum UserSource: Equatable {
        case loggedIn
        case id(String)
    }
    
    enum InfoState: Equatable {
        case list
        case images
        case info
    }
    
    @State var user: User?
    @State var error: String?
    @State var userSource: UserSource
    @State var infoState: InfoState = .list
    @State var asyncImageId: String = UUID().uuidString
    var body: some View {
        if let user = self.user {
            ScrollView {
                VStack {
                    if user.profilePictureName == nil {
                        Image("userIcon")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 130, height: 130)
                            .clipped()
                            .mask { RoundedRectangle(cornerRadius: 67, style: .continuous) }
                            .padding()
                    } else {
                        AsyncImage(url: URL(string: "https://skilllinkr.micstudios.de/public/profilepictures/\(user.profilePictureName ?? user.id)")) { phase in
                            if let image = phase.image {
                                image
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 130, height: 130)
                                    .clipped()
                                    .mask { RoundedRectangle(cornerRadius: 67, style: .continuous) }
                                    .padding()
                            } else {
                                Rectangle()
                                    .foregroundStyle(.fill)
                                    .frame(width: 130, height: 130)
                                    .clipped()
                                    .mask { RoundedRectangle(cornerRadius: 67, style: .continuous) }
                                    .overlay {
                                        ProgressView()
                                    }
                                    .padding()
                            }
                        }
                        .id(asyncImageId)
                    }
                    /*
                    HStack(spacing: 4) {
                        VStack {
                            Text(user.createdAt)
                                .font(.system(.headline, weight: .semibold))
                            Text("joined")
                                .font(.footnote)
                        }
                        .frame(width: 80)
                        .clipped()
                    }
                    .padding()
                     */
                    VStack(spacing: 4) {
                        Text("\(user.firstname) \(user.lastname)")
                            .font(.headline)
                        Text(user.biography ?? "")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 250)
                    .clipped()
                    .padding(.bottom, 20)
                    Divider()
                    HStack {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                            Button {
                                withAnimation(.snappy(duration: 0.25)) {
                                    infoState = .list
                                }
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(.background)
                                    Image(systemName: "list.bullet")
                                        .foregroundStyle(infoState == .list ? .accent : .secondary)
                                }
                            }
                            Button {
                                withAnimation(.snappy(duration: 0.25)) {
                                    infoState = .images
                                }
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(.background)
                                    Image(systemName: "photo")
                                        .foregroundStyle(infoState == .images ? .accent : .secondary)
                                }
                            }
                            Button {
                                withAnimation(.snappy(duration: 0.25)) {
                                    infoState = .info
                                }
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .foregroundStyle(.background)
                                    Image(systemName: "info.circle")
                                        .foregroundStyle(infoState == .info ? .accent : .secondary)
                                }
                            }
                        }
                    }
                    .font(.title2)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 4)
                    if infoState == .list {
                        
                    } else if infoState == .images {
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1), GridItem(.flexible(), spacing: 1)], spacing: 1) {
                            ForEach(0..<5) { _ in // Replace with your data model here
                                Image("Logo")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
                                    .aspectRatio(1/1, contentMode: .fit)
                                    .clipped()
                            }
                        }
                    } else {
                        Text("Name: \(user.firstname) \(user.lastname)")
                        Text("Joined: \(DateDataManager().iso8601StringToFormattedDate(user.createdAt) ?? "Unknown")")
                    }
                }
                .frame(maxWidth: .infinity)
                .clipped()
                .padding(.top, 10)
                .padding(.bottom, 150)
            }
            .refreshable {
                getUser()
                asyncImageId = UUID().uuidString
            }
            .navigationTitle(userSource == .loggedIn ? "My Profile" : "\(user.firstname) \(user.lastname)")
            .navigationBarTitleDisplayMode(userSource == .loggedIn ? .large : .inline)
            .toolbar {
                if UserSource.loggedIn == userSource {
                    NavigationLink {
                        SettingsView(user: user)
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                } else {
                    Button {
                        
                    } label: {
                        Image(systemName: "paperplane.fill")
                    }
                    
                    Menu {
                        Button("Block", role: .destructive) {
                            
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        } else {
            if error == nil {
                ProgressView()
                    .onAppear {
                        getUser()
                    }
            }
            if let error = error {
                ErrorView(error: error) {
                    getUser()
                }
            }
        }
    }
    
    func getUser() {
        error = nil
        if userSource == .loggedIn {
            HTTPManager().getLoggedInUser { result in
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    self.error = "Error fetching user: \(error.localizedDescription)"
                }
            }
        } else if case .id(let id) = userSource {
            HTTPManager().getUser(id: id) { result in
                switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    self.error = "Error fetching user: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ProfileView(user: defaultUser, userSource: .loggedIn)
    }
}
