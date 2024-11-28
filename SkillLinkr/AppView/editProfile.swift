//
//  editProfile.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI
import Foundation
import Combine
import PhotosUI

struct EditProfileView: View {
    @State var user: User
    
    @State var userBiography: String = ""
    @State var biographyLimit: Int = 500
    @State var biographyCurrent: Int = 0
    
    @State var imageSelection: PhotosPickerItem?
    @State var image: Image?
    @State var jpegData: Data?
    @State var id: String = UUID().uuidString
    var body: some View {
        List {
            Section("Profile Picture") {
                PhotosPicker(selection: $imageSelection) {
                    HStack {
                        if let image = image {
                            image
                                .renderingMode(.original)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 130, height: 130)
                                .clipped()
                                .mask { RoundedRectangle(cornerRadius: 67, style: .continuous) }
                                .padding()
                        } else {
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
                                .id(id)
                            }
                        }
                        Text("Edit...")
                    }
                }
                .onChange(of: imageSelection) { oldValue, newValue in
                    Task {
                        if let data = try? await imageSelection?.loadTransferable(type: Data.self) {
                            jpegData = data
                        } else {
                            print("Failed to upload image 298:1")
                        }
                    }
                }
                .onChange(of: imageSelection) { oldValue, newValue in
                    Task {
                        if let loaded = try? await imageSelection?.loadTransferable(type: Image.self) {
                            image = loaded
                        } else {
                            print("Failed to set image 298:2")
                        }
                    }
                }
                .onChange(of: jpegData) { oldValue, newValue in
                    if let jpegData = newValue {
                        uploadImage(data: jpegData)
                    } else {
                        print("Failed to upload image 298:3")
                    }
                }
                Button("Reset to default", role: .destructive) {
                    deleteImage()
                }
            }
            Section("General Information") {
                TextField("Firstname", text: $user.firstname)
                    .onChange(of: user.firstname, { oldValue, newValue in
                        if user.firstname.isEmpty {
                            user.firstname = oldValue
                        }
                    })
                TextField("Lastname", text: $user.lastname)
                    .onChange(of: user.lastname, { oldValue, newValue in
                        if user.lastname.isEmpty {
                            user.lastname = oldValue
                        }
                    })
                VStack(alignment: .trailing) {
                    TextField("Biography", text: $userBiography, axis: .vertical)
                        .onReceive(Just(userBiography)) { _ in
                            limitText()
                        }
                        .onSubmit {
                            if userBiography.isEmpty {
                                user.biography = nil
                            } else {
                                user.biography = userBiography
                            }
                        }
                    if biographyCurrent != 0 {
                        Text(biographyCurrent == biographyLimit ? "Max length reached" : "\(biographyCurrent)/\(biographyLimit)")
                            .foregroundStyle(biographyCurrent == biographyLimit ? .red : .primary)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Edit Profile")
        .onAppear {
            if let biography = self.user.biography {
                userBiography = biography
                biographyCurrent = biography.count
            }
        }
        .onChange(of: user) { oldValue, newValue in
            save()
        }
    }
    
    func limitText() {
        if biographyCurrent > biographyLimit {
            userBiography = String(userBiography.prefix(biographyLimit))
        }
        biographyCurrent = userBiography.count
        user.biography = userBiography
    }
    
    func save() {
        HTTPManager().patchUser(patchUserId: user.id, firstname: user.firstname, lastname: user.lastname, biography: user.biography) { result in
            switch result {
            case .success(let response):
                print("Successfully patched user: \(response.message)")
                id = UUID().uuidString
            case .failure(let error):
                print("Error patching user: \(error.localizedDescription)")
            }
        }
    }
    
    func uploadImage(data: Data) {
        HTTPManager().updateProfilePicture(jpegDataImage: data) { result in
            switch result {
            case .success(let response):
                print(response.message)
                id = UUID().uuidString
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteImage() {
        user.profilePictureName = nil
        image = nil
        jpegData = nil
        imageSelection = nil
        
        HTTPManager().deleteProfilePicture { result in
            switch result {
            case .success(let response):
                print(response)
                id = UUID().uuidString
            case .failure(let error):
                print(error)
            }
        }
    }
}

#Preview {
    EditProfileView(user: defaultUser)
}
