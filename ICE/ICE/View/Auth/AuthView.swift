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
                VStack(alignment: .center, spacing: 25) {
                    icon()
                        .padding(.top, 70)
                    if vm.navHostOrGuest {
                        HostOrGuestSection()
                            .transition(.opacity)
                    } else if vm.navSignIn {
                        SignInSection()
                            .transition(.opacity)
                    } else if vm.navSignUp {
                        SignUpSection()
                            .transition(.opacity)
                    } else if vm.navSignUpConfirm {
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
            .alert(isPresented: $vm.alert) {
                Alert(
                    title: Text(
                        "認証エラー"
                    ),
                    message: Text(
                        vm.alertMessage ?? "操作をやり直してください。"
                    ),
                    dismissButton: .default(
                        Text(
                            "閉じる"
                        )
                    )
                )
            }
            .onOpenURL(perform: { url in
                debugPrint(url)
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                      let queryItems = components.queryItems {
                    if let inviteCode = queryItems.first(where: { $0.name == "code" })?.value {
                        // 招待コードを使って何かする
                        // 例: サインアップ画面に遷移し、招待コードをセットする
                        if !inviteCode.isEmpty {
                            print("code is \(inviteCode)")
                            vm.signUpOptions.invitedGroupID = inviteCode
                            vm.isSignUp = true
                            vm.navSignUp = true
                        }
                    }
                }

            })
        case let .failed(error):
            Text(error.localizedDescription)
        }
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
//                .navigationDestination(isPresented: $vm.authComplete) {
//                    HomeView(vm: .init())
//                }
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
//                .navigationDestination(isPresented: $vm.authComplete) {
//                    HomeView(vm: .init())
//                }
            ActionFillButton(label: "コード再送", action: vm.resendCode, color: Color(.indigo))
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
