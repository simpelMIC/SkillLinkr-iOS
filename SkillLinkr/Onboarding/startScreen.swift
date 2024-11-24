//
//  startScreen.swift
//  SkillLinkr
//
//  Created by Christian on 24.11.24.
//

import SwiftUI
import Foundation

struct StartScreen: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Image("SocialImage")
                .resizable()
                .ignoresSafeArea()
                .aspectRatio(contentMode: .fill)
            StartScreenRectangle() { login in
                
            }
        }
    }
}

struct StartScreenRectangle: View {
    var completion: (Bool) -> Void //Register: true, Login: false
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(.regularMaterial)
                .cornerRadius(40)
                .frame(width: 380, height:  210)
            VStack {
                VStack(alignment: .leading) {
                    Text("Explore & Learn Skills")
                        .font(.system(size: 32, weight: .bold, design: .default))
                    Text("In SkillLinkr you can find and learn skills from the world of coding, design, and more.")
                }
                .padding()
                HStack {
                    Button {
                        completion(true)
                    } label: {
                        ZStack {
                            Rectangle()
                                .cornerRadius(15)
                            Text("Create Account")
                                .foregroundStyle(.background)
                                .font(.system(size: 19, weight: .regular, design: .default))
                        }
                    }
                    .frame(height: 60)
                    .padding(.leading)
                    .padding(.bottom)
                    
                    Button {
                        completion(false)
                    } label: {
                        ZStack {
                            Rectangle()
                                .cornerRadius(15)
                            Text("Login")
                                .foregroundStyle(.background)
                                .font(.system(size: 19, weight: .regular, design: .default))
                        }
                    }
                    .frame(height: 60)
                    .padding(.trailing)
                    .padding(.bottom)
                }
            }
            .frame(width: 380, height:  210)
        }
    }
}

#Preview {
    StartScreen()
}
