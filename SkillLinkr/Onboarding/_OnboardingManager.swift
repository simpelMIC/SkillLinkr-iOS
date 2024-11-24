//
//  OnboardingManager.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI
import Foundation

struct OnboardingManager: View {
    enum LoginStage {
        case login
        case register
        case welcome
    }
    
    @State var loginStage: LoginStage = .register
    
    var completion: (Bool) -> Void
    
    var body: some View {
        if loginStage == .login {
            LoginView { login in
                if login {
                    completion(true)
                } else {
                    loginStage = .register
                }
            }
        } else if loginStage == .register {
            RegisterView { register in
                if register {
                    completion(true)
                } else {
                    loginStage = .login
                }
            }
        } else {
            Text("Error")
        }
    }
}

struct TextBox: View {
    enum TextType {
        case name
        case email
        case password
    }
    
    @State var type: TextType
    @State var label: String
    @Binding var text: String
    @Binding var isDisabled: Bool
    
    var body: some View {
        ZStack {
            if type == .name {
                Rectangle()
                    .cornerRadius(12)
                    .foregroundStyle(.thinMaterial)
                    .frame(height: 50)
                TextField(label, text: $text)
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                    .keyboardType(.default)
                    .textContentType(.name)
                    .disabled($isDisabled.wrappedValue)
            } else if type == .email {
                Rectangle()
                    .cornerRadius(12)
                    .foregroundStyle(.thinMaterial)
                    .frame(height: 50)
                TextField(label, text: $text)
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .disabled($isDisabled.wrappedValue)
            } else if type == .password {
                Rectangle()
                    .cornerRadius(12)
                    .foregroundStyle(.thinMaterial)
                    .frame(height: 50)
                SecureField(label, text: $text)
                    .foregroundStyle(.white)
                    .textFieldStyle(.plain)
                    .padding(.horizontal)
                    .autocorrectionDisabled()
                    .textContentType(.password)
                    .disabled($isDisabled.wrappedValue)
            }
        }
    }
}
