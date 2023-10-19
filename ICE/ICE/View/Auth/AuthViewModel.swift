//
//  AuthViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import SwiftUI
import Amplify

final class AuthViewModel: ObservableObject {
    @Published var state: LoadingState = .idle
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var confirmationCode: String = ""
    @Published var asGuest: Bool = false
    
    @Published var signInInfo: AuthSignInResult?
    @Published var signUpInfo: AuthSignUpResult?
    
    @Published var navSignIn: Bool = false
    @Published var navSignUp: Bool = false
    @Published var navSignUpConfirm: Bool = false
    
    
    @Published var authComplete: Bool = false
    
    @ObservedObject var auth = AmplifyAuthService()
    
    @MainActor
    func signUp() async throws {
        if !userName.isEmpty, !email.isEmpty, !password.isEmpty {
            do {
                signUpInfo = try await auth.signUp(username: userName, password: password, email: email)
                if case .confirmUser(_, _, _) = signUpInfo?.nextStep {
                    withAnimation(.easeIn) {
                        navSignUpConfirm = true
                    }
                } else if case .done = signUpInfo?.nextStep {
                    authComplete = true
                } else {
                    throw AmplifyAuthError.signUpFailed
                }
            } catch let error {
                state = .failed(error)
            }
        }
        if !navSignUpConfirm {
            withAnimation(.easeIn) {
                navSignUp = true
            }
        }
    }
    
    @MainActor
    func signUpConfirmation() async throws {
        if !userName.isEmpty, !confirmationCode.isEmpty {
            do {
                signUpInfo = try await auth.confirmSignUp(for: userName, with: confirmationCode)
                if let signUpInfo = signUpInfo, signUpInfo.isSignUpComplete, let userID = signUpInfo.userID {
                    auth.userID = userID
                    withAnimation(.easeIn) {
                        authComplete = true
                    }
                } else {
                    throw AmplifyAuthError.confirmError
                }
            } catch let error {
                state = .failed(error)
            }
        }
    }
    
    @MainActor
    func signIn() async throws {
        if !userName.isEmpty, !password.isEmpty  {
            do {
                signInInfo = try await auth.signIn(username: userName, password: password)
                if let signInInfo = signInInfo, signInInfo.isSignedIn {
                    withAnimation(.easeIn) {
                        authComplete = true
                    }
                } else {
                    throw AmplifyAuthError.signInFailed
                }
            } catch let error {
                state = .failed(error)
            }
        }
        if !authComplete {
            withAnimation(.easeIn) {
                navSignIn = true
            }
        }
    }
}
