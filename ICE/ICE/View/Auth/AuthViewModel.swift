//
//  AuthViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import SwiftUI
import Amplify
import Combine
import Foundation

final class AuthViewModel: ObservableObject {
    @Published var state: LoadingState = .idle
    @Published var signInValid: Validation = .failed()
    @Published var signUpValid: Validation = .failed()
    @Published var codeValid: Validation = .failed()
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
    
    @Published var alert: Bool = false
    @Published var alertMessage: String?
    
    @ObservedObject var auth = AmplifyAuthService()
    @ObservedObject var apiHandler = APIHandler()
    
    let hashDelimiter = "_hash_"
    
    @Published var isLoading: Bool = false
    private var publishers = Set<AnyCancellable>()
    
    init()
    {
        signInValidation
            .receive(on: RunLoop.main)
            .assign(to: \.signInValid, on: self)
            .store(in: &publishers)
        hostSignUpValidation
            .receive(on: RunLoop.main)
            .assign(to: \.signUpValid, on: self)
            .store(in: &publishers)
        codeValidation
            .receive(on: RunLoop.main)
            .assign(to: \.codeValid, on: self)
            .store(in: &publishers)
    }
    
    var userNameValidation: AnyPublisher<Validation, Never> {
        $userName
            .dropFirst()
            .map { value in
                if value.containsEmoji() {
                    return .failed(message: "絵文字は入力できません")
                }
                return .success
            }
            .eraseToAnyPublisher()
    }

    var passwordValidation: AnyPublisher<Validation, Never> {
        $password
            .dropFirst()
            .map { value in
                if value.containsEmoji() {
                    return .failed(message: "絵文字は入力できません")
                }
                if value.count < 8 {
                    return .failed(message: "8文字以上設定してください。")
                }
                if !value.isMatch(pattern: Regex.alphanumeric) {
                    return .failed(message: "英数字を含めて設定してください。")
                }
                return .success
            }
            .eraseToAnyPublisher()
    }
    
    var codeValidation: AnyPublisher<Validation, Never> {
        $confirmationCode
            .dropFirst()
            .map { value in
                if !value.isMatch(pattern: Regex.confirmationCode) {
                    return .failed(message: "正しいコードを入力してください")
                }
                if value.containsEmoji() {
                    return .failed(message: "絵文字は入力できません")
                }
                return .success
            }
            .eraseToAnyPublisher()
    }
    
    var emailValidation: AnyPublisher<Validation, Never> {
        $email
            .dropFirst()
            .map { value in
                if !value.isMatch(pattern: Regex.email) {
                    return .failed(message: "メールアドレスの形式で入力してください。")
                }
                return .success
            }
            .eraseToAnyPublisher()
    }
    
    var hostSignUpValidation: AnyPublisher<Validation, Never> {
        Publishers.CombineLatest3(
            emailValidation,
            userNameValidation,
            passwordValidation
        )
        .map { v1, v2, v3 in
            [v1, v2, v3].allSatisfy(\.isSuccess) ? .success : .failed()
        }
        .eraseToAnyPublisher()
    }
    
    var signInValidation: AnyPublisher<Validation, Never> {
        Publishers.CombineLatest3(
            emailValidation,
            userNameValidation,
            passwordValidation
        )
        .map { v1, v2, v3 in
            [v1, v2, v3].allSatisfy(\.isSuccess) ? .success : .failed()
        }
        .eraseToAnyPublisher()
    }
    
    @MainActor
    func signUp() async throws {
        isLoading = true
        defer { isLoading = false }
        if !userName.isEmpty, !password.isEmpty {
            do {
                if asGuest {
                    signUpInfo = try await auth.signUp(username: userName, password: password, email: nil)
                } else if !email.isEmpty {
                    let hashedEmail = hashDelimiter + String(email.hashed())
                    signUpInfo = try await auth.signUp(username: userName + hashedEmail , password: password, email: email)
                } else {
                    throw AmplifyAuthError.signUpFailed
                }
                
                if case .confirmUser(_, _, _) = signUpInfo?.nextStep {
                    UserDefaults.standard.set(signUpInfo?.userID, forKey:"userID")
                    withAnimation(.easeIn) {
                        navSignUp = false
                        navSignUpConfirm = true
                    }
                } else if case .done = signUpInfo?.nextStep {
                    try await createUser()
                } else {
                    throw AmplifyAuthError.signUpFailed
                }
                
            } catch let error as AmplifyAuthError {
                switch error {
                case .userAlreadyExists:
                    alertMessage = error.localizedDescription
                    alert = true
                    navSignIn = true
                default:
                    alertMessage = error.localizedDescription
                    alert = true
                }
            } catch let error {
                alertMessage = error.localizedDescription
                alert = true
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
        isLoading = true
        defer { isLoading = false }
        if !userName.isEmpty, !confirmationCode.isEmpty {
            let hashedEmail = hashDelimiter + String(email.hashed())
            do {
                signUpInfo = try await auth.confirmSignUp(for: userName + hashedEmail, with: confirmationCode)
                if let signUpInfo = signUpInfo, signUpInfo.isSignUpComplete {
                    try await createUser()
                } else {
                    throw AmplifyAuthError.confirmError
                }
            } catch let error {
                alertMessage = error.localizedDescription
                alert = true
            }
        }
    }
    
    @MainActor
    func signIn() async throws {
        isLoading = true
        defer { isLoading = false }
        if !userName.isEmpty, !password.isEmpty, !email.isEmpty  {
            let hashedEmail = hashDelimiter + String(email.hashed())
            do {
                signInInfo = try await auth.signIn(username: userName + hashedEmail, password: password)
                if let signInInfo = signInInfo, signInInfo.isSignedIn {
                    withAnimation(.easeIn) {
                        authComplete = true
                    }
                } else if case .confirmSignUp(_) = signInInfo?.nextStep {
                    withAnimation(.easeIn) {
                        navSignIn = false
                        navSignUpConfirm = true
                    }
                } else {
                    throw AmplifyAuthError.signInFailed
                }
            } catch let error as AuthError {
                alertMessage = error.localizedDescription
                alert = true
            }
        } else if !authComplete {
            withAnimation(.easeIn) {
                navSignIn = true
            }
        }
    }
    
    @MainActor
    func createUser() async throws {
        do {
            guard let userID = UserDefaults.standard.string(forKey: "userID"), !userID.isEmpty else {
                throw AmplifyAuthError.signUpFailed
            }
            let user = User(userID: userID, userName: userName, accountType: asGuest ? AccountType.guest : AccountType.host)
            try await apiHandler.create(user)
            withAnimation(.easeIn) {
                authComplete = true
            }
        } catch {
            alertMessage = APIError.createFailed.localizedDescription
            alert = true
        }
    }
    
    @MainActor
    func propertyInitialize() {
        withAnimation(.linear) {
            userName = ""
            email = ""
            password = ""
            confirmationCode = ""
            navSignIn = false
            navSignUp = false
            navSignUpConfirm = false
            asGuest = false
            authComplete = false
        }
    }
}
