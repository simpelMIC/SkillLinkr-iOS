//
//  register.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI
import Foundation

struct RegisterView: View {
    @State var firstname: String = ""
    @State var lastname: String = ""
    @State var mail: String = ""
    @State var password: String = ""
    @State var passwordConfirm: String = ""
    
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
                    Text("Welcome!")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    HStack {
                        Text("Please enter all your personal data to continue.")
                        Button("I already have an account") {
                            back()
                        }
                        .disabled(isLoading)
                    }
                }
                VStack {
                    if let error = self.error {
                        ZStack {
                            Rectangle()
                                .cornerRadius(12)
                                .foregroundStyle(.thinMaterial)
                                .frame(height: 440)
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
                            .frame(height: 420)
                            .padding(.horizontal, 10)
                            .padding(.leading, 10)
                        }
                    } else {
                        TextBox(type: .name, label: "Firstname", text: $firstname, isDisabled: $isLoading)
                        TextBox(type: .name, label: "Lastname", text: $lastname, isDisabled: $isLoading)
                        TextBox(type: .email, label: "Email", text: $mail, isDisabled: $isLoading)
                        TextBox(type: .password, label: "Password", text: $password, isDisabled: $isLoading)
                        TextBox(type: .password, label: "Confirm password", text: $passwordConfirm, isDisabled: $isLoading)
                    }
                }
                Spacer()
                    .frame(height: 10)
                if error == nil {
                    Button {
                        isLoading = true
                        register()
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
                    .disabled(mail.isEmpty || isLoading)
                }
            }
            .frame(width: 350)
        }
    }
    
    func back() {
        completion(false)
    }
    
    func register() {
        isLoading = true
        HTTPManager().register(mail: $mail.wrappedValue, firstname: $firstname.wrappedValue, lastname: $lastname.wrappedValue, password: $password.wrappedValue, passwordConfirm: $passwordConfirm.wrappedValue) { result in
            switch result {
            case .success(let response):
                registerSuccess(token: response.message.token)
            case .failure(let error):
                registerFailure(error: error.localizedDescription)
            }
        }
    }
    
    func registerSuccess(token: String) {
        SecureDataManager().saveToken(token) { result in
            switch result {
            case .success:
                print("Successfully saved token")
            case .failure:
                registerFailure(error: "Failed to save token")
            }
        }
        completion(true)
    }
    
    func registerFailure(error: String) {
        isLoading = false
        self.error = error
    }
}

#Preview {
    RegisterView(error: "gdiusghih huih dfiushfiuds fhiu dsfi dhsiuf udsf hids fuds fhuidsfds fiudshfiuds fhui dshiuf dhsiuf hdsiu fs") { register in
        
    }
}
