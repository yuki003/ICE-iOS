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
            VStack(alignment: .center, spacing: 25) {
                Icon()
                    .padding(.top, 70)
                if vm.navHostOrGuest {
                    // host or guest button
                    HostOrGuestSection()
                        .transition(.opacity)
                } else if vm.navSignIn {
                    // sign in view
                    SignInSection()
                        .transition(.opacity)
                } else if vm.navSignUp {
                    // sign up view
                    SignUpSection()
                        .transition(.opacity)
                } else if vm.navSignUpConfirm {
                    // confirmation code view
                    ConfirmationCodeSection()
                        .transition(.opacity)
                } else {
                    // default view
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
                // Except default view
                if vm.navSignIn || vm.navSignUp || vm.navSignUpConfirm || vm.navHostOrGuest {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            if vm.navHostOrGuest {
                                vm.flagInitialize()
                                vm.isSignIn = false
                                vm.isSignUp = false
                            } else if vm.navSignIn || vm.navSignUp {
                                vm.propertyInitialize()
                                vm.flagInitialize()
                                vm.navHostOrGuest = true
                            } else if vm.navSignUpConfirm {
                                vm.flagInitialize()
                                vm.navSignUp = true
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
        .loading(isLoading: $vm.isLoading)
        .popupAlert(prop: $vm.authErrorPopAlertProp)
        .onOpenURL(perform: { url in
            // invited code auto fill
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
               let queryItems = components.queryItems {
                if let inviteCode = queryItems.first(where: { $0.name == "code" })?.value {
                    if !inviteCode.isEmpty {
                        print("code is \(inviteCode)")
                        vm.signUpOptions.invitedGroupID = inviteCode
                        vm.isSignUp = true
                        vm.navSignUp = true
                    }
                }
            }
            
        })
    }
    @ViewBuilder
    func HostOrGuestSection() -> some View {
        VStack(spacing: 20) {
            HostUserButton(vm: vm)
            GuestUserButton(vm: vm)
        }
        .frame(height: 150)
        .padding()
    }
    
    @ViewBuilder
    func SignInSection() -> some View {
        VStack(spacing: 20) {
            if !vm.asHost {
                InvitedGroupTextField(groupID: $vm.signUpOptions.invitedGroupID, focused: _focused)
            } else {
                EmailTextField(email: $vm.signUpOptions.email, focused: _focused)
                    .validation(vm.optionsValidation)
            }
            UsernameTextField(userName: $vm.userName, focused: _focused)
                .validation(vm.userNameValidation)
            
            PasswordTextField(password: $vm.password, focused: _focused)
                .validation(vm.passwordValidation)
            
            SignInButton(vm: vm)
                .disabled(vm.signInValid.isSuccess == false)
        }
        .frame(height: 150)
        .padding()
    }
    
    @ViewBuilder
    func SignUpSection() -> some View {
        VStack(spacing: 20) {
            if !vm.asHost {
                InvitedGroupTextField(groupID: $vm.signUpOptions.invitedGroupID, focused: _focused)
            } else {
                EmailTextField(email: $vm.signUpOptions.email, focused: _focused)
                    .validation(vm.optionsValidation)
            }
            UsernameTextField(userName: $vm.userName, focused: _focused)
                .validation(vm.userNameValidation)
            
            PasswordTextField(password: $vm.password, focused: _focused)
                .validation(vm.passwordValidation)
            
            SignUpButton(vm: vm)
                .disabled(vm.signUpValid.isSuccess == false)
        }
        .frame(height: 150)
        .padding()
    }
    
    @ViewBuilder
    func ConfirmationCodeSection() -> some View {
        VStack(spacing: 20) {
            ConfirmationCodeTextField(code: $vm.confirmationCode, focused: _focused)
                .validation(vm.codeValidation)
            
            ConfirmSignUpButton(vm: vm)
                .disabled(vm.codeValid.isSuccess == false)
            ActionFillButton(label: "コード再送", action: vm.resendCode, color: Color(.indigo))
        }
        .frame(height: 150)
        .padding()
    }
}



//#Preview {
//    AuthView(vm: .init())
//}
