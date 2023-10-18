//
//  AuthView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import SwiftUI

struct AuthView: View {
    @StateObject var vm: AuthViewModel
    @FocusState private var focused: AuthField?
    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 15) {
                icon()
                    .padding(.top, 60)
                if vm.navSignIn {
                    SignInSection()
                        .transition(.opacity)
                } else if vm.navSignUp {
                    SignUpSection()
                        .transition(.opacity)
                } else {
                    VStack(spacing: 20){
                        SignInButton(navSignIn: $vm.navSignIn)
                        SignUpButton(navSignIUp: $vm.navSignUp)
                    }
                        .frame(height: 120)
                        .padding()
                }
                Spacer()
            }
            .toolbar {
                if vm.navSignIn || vm.navSignUp {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            vm.navSignIn = false
                            vm.navSignUp = false
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.callout)
                                .foregroundStyle(Color(.indigo))
                        }
                    }
                } else {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Text("")
                            .font(.callout)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func SignInSection() -> some View {
        VStack(spacing: 20) {
            UsernameTextField(userName: $vm.userName, focused: _focused)
            
            PasswordTextField(password: $vm.password, focused: _focused)
        }
        .frame(height: 120)
        .padding()
    }
    
    @ViewBuilder
    func SignUpSection() -> some View {
        VStack(spacing: 20) {
            EmailTextField(email: $vm.email, focused: _focused)
            
            PasswordTextField(password: $vm.password, focused: _focused)
            
            LoginAsGuestButton(asGuest: $vm.asGuest)
        }
        .frame(height: 120)
        .padding()
    }
}

@ViewBuilder
func icon() -> some View {
        Image(.logo)
            .resizable()
            .scaledToFit()
            .frame(width: UIScreen.main.bounds.width / 1.8)
}


//#Preview {
//    AuthView(vm: .init())
//}
