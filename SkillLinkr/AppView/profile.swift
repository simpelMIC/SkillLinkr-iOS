//
//  profile.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI
import Foundation

struct ProfileView: View {
    @State var user: User?
    @State var error: String?
    var body: some View {
        if let user = user {
            ScrollView {
                Text(user.firstname)
            }
            .refreshable {
                getUser()
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
        HTTPManager().getLoggedInUser { result in
            switch result {
            case .success(let user):
                self.user = user
            case .failure(let error):
                self.error = "Error fetching user: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    ProfileView(user: defaultUser)
}
