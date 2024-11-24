//
//  login.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI
import Foundation

struct LoginView: View {
    @State var mail: String = ""
    @State var password: String = ""
    
    @State var isLoading: Bool = false
    @State var error: String?
    
    var completion: (Bool) -> Void
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .foregroundStyle(.linearGradient(colors: [.accentColor, .black], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 1000, height: 400)
                .rotationEffect(.degrees(135))
                .offset(y: -350)
            VStack {
                VStack {
                    Image("Logo")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(50)
                        .shadow(radius: 10)
                    Text("Welcome Back!")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    HStack {
                        Text("Please enter your email and password to continue.")
                        Button("I don't have an account") {
                            back()
                        }
                        .disabled(isLoading)
                    }
                }
                VStack {
                    ZStack {
                        if let error = self.error {
                            Rectangle()
                                .cornerRadius(12)
                                .foregroundStyle(.thinMaterial)
                                .frame(height: 110)
                            HStack {
                                Text(error)
                                    .foregroundStyle(.red)
                                Spacer()
                                Button {
                                    self.error = nil
                                    isLoading = false
                                } label: {
                                    ZStack {
                                        Rectangle()
                                            .cornerRadius(12)
                                            .foregroundStyle(.red)
                                        Text("Try again")
                                    }
                                }
                                .frame(width: 100)
                                .buttonStyle(.plain)
                            }
                            .frame(height: 90)
                            .padding(.horizontal, 10)
                            .padding(.leading, 10)
                        } else {
                            TextBox(type: .email, label: "Email", text: $mail, isDisabled: $isLoading)
                        }
                    }
                    
                    ZStack {
                        if self.error == nil {
                            TextBox(type: .password, label: "Password", text: $password, isDisabled: $isLoading)
                        }
                    }
                }
                Spacer()
                    .frame(height: 10)
                if error == nil {
                    Button {
                        isLoading = true
                        login()
                    } label: {
                        ZStack(alignment: .center) {
                            Rectangle()
                                .cornerRadius(12)
                                .frame(height: 50)
                            Text(isLoading ? "Is validating ..." : "Continue")
                                .foregroundStyle(.background)
                        }
                    }
                    .padding(.bottom, 30)
                    .disabled(mail.isEmpty || password.isEmpty || isLoading)
                }
            }
            .frame(width: 350)
        }
    }
    
    func back() {
        completion(false)
    }
    
    func login() {
        isLoading = true
        HTTPManager().login(mail: $mail.wrappedValue, password: $password.wrappedValue) { result in
            switch result {
            case .success(let response):
                loginSuccess(token: response.message.token)
            case .failure(let error):
                loginFailure(error: error.localizedDescription)
            }
        }
    }
    
    func loginSuccess(token: String) {
        SecureDataManager().saveToken(token) { result in
            switch result {
            case .success:
                print("Successfully saved token")
            case .failure:
                loginFailure(error: "Failed to save token")
            }
        }
        completion(true)
    }
    
    func loginFailure(error: String) {
        isLoading = false
        self.error = error
    }
}

#Preview {
    LoginView() { login in
        
    }
}
