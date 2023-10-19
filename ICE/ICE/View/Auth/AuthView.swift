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
        switch vm.state {
        case .idle:
            Color.clear.onAppear { vm.state = .loading }
        case .loading:
            Color.clear.onAppear { vm.state = .loaded }
        case .loaded:
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
                    } else if vm.navSignUpConfirm{
                        ConfirmationCodeSection()
                            .transition(.opacity)
                    } else {
                        VStack(spacing: 20){
                            SignInButton(vm: vm)
                            SignUpButton(vm: vm)
                        }
                        .frame(height: 120)
                        .padding()
                    }
                    Spacer()
                }
                .toolbar {
                    if vm.navSignIn || vm.navSignUp || vm.navSignUpConfirm {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                if vm.navSignIn || vm.navSignUp {
                                    vm.navSignIn = false
                                    vm.navSignUp = false
                                } else if vm.navSignUpConfirm {
                                    vm.navSignUpConfirm = false
                                }
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
            .navigationDestination(isPresented: $vm.authComplete) {
                HomeView()
            }
        case let .failed(error):
            Text(error.localizedDescription)
        }
    }
    
    @ViewBuilder
    func SignInSection() -> some View {
        VStack(spacing: 20) {
            UsernameTextField(userName: $vm.userName, focused: _focused)
            
            PasswordTextField(password: $vm.password, focused: _focused)
            
            SignInButton(vm: vm)
        }
        .frame(height: 150)
        .padding()
    }
    
    @ViewBuilder
    func SignUpSection() -> some View {
        VStack(spacing: 20) {
            EmailTextField(email: $vm.email, focused: _focused)
            
            UsernameTextField(userName: $vm.userName, focused: _focused)
            
            PasswordTextField(password: $vm.password, focused: _focused)
            
            SignUpButton(vm: vm)
            
            LoginAsGuestButton(asGuest: $vm.asGuest)
        }
        .frame(height: 150)
        .padding()
    }
    
    @ViewBuilder
    func ConfirmationCodeSection() -> some View {
        VStack(spacing: 20) {
            ConfirmationCodeTextField(code: $vm.confirmationCode, focused: _focused)
            
            ConfirmSignUpButton(vm: vm)
        }
        .frame(height: 150)
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
