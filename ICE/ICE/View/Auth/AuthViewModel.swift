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
    @Published var signInValid: Validation = .failed()
    @Published var signUpValid: Validation = .failed()
    @Published var codeValid: Validation = .failed()
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var signUpOptions: SignUpOptions = .init()
    @Published var confirmationCode: String = ""
    var hashedKey: String = ""
    @Published var userID: String = ""
    @Published var asHost: Bool = false
    @Published var isSignIn: Bool = false
    @Published var isSignUp: Bool = false
    
    @Published var signInInfo: AuthSignInResult?
    @Published var signUpInfo: AuthSignUpResult?
    
    @Published var navHostOrGuest: Bool = false
    @Published var navSignIn: Bool = false
    @Published var navSignUp: Bool = false
    @Published var navSignUpConfirm: Bool = false
    
    @ObservedObject var auth = AmplifyAuthService.shared
    @ObservedObject var apiHandler = APIHandler.shared
    
    @Published var authErrorPopAlertProp: PopupAlertProperties = .init(title: "認証エラー", text: "操作をやり直してください。")
    
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
    
    // MARK: Validation
    var userNameValidation: AnyPublisher<Validation, Never> {
        $userName
            .dropFirst()
            .map { value in
                if value.containsEmoji() {
                    return .failed(message: "絵文字は入力できません")
                }
                if value.count <= 0 {
                    return .failed(message: "ユーザー名を入力してください。")
                }
                if !value.isMatch(pattern: Regex.userName) {
                    return .failed(message: "ユーザー名に空白は使用できません")
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
    
    var optionsValidation: AnyPublisher<Validation, Never> {
        $signUpOptions
            .dropFirst()
            .map { value in
                if self.asHost, !value.email.isMatch(pattern: Regex.email) {
                    return .failed(message: "メールアドレスの形式で入力してください。")
                }
                if !self.asHost, value.invitedGroupID.isEmpty {
                    return .failed()
                }
                return .success
            }
            .eraseToAnyPublisher()
    }
    
    var hostSignUpValidation: AnyPublisher<Validation, Never> {
        Publishers.CombineLatest3(
            optionsValidation,
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
            optionsValidation,
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
                if !asHost {
                    hashedKey = hashDelimiter + String(signUpOptions.invitedGroupID.hashed())
                    signUpInfo = try await auth.signUp(username: userName + hashedKey, password: password, name: userName, groupID: signUpOptions.invitedGroupID)
                } else if !signUpOptions.email.isEmpty {
                    hashedKey = hashDelimiter + String(signUpOptions.email.hashed())
                    signUpInfo = try await auth.signUp(username: userName + hashedKey , password: password, name: userName, email: signUpOptions.email)
                } else {
                    throw AmplifyAuthError.signUpFailed
                }
                
                if case .confirmUser(_, _, _) = signUpInfo?.nextStep {
                    guard let id = signUpInfo?.userID else { throw AmplifyAuthError.signUpFailed }
                    UserDefaults.standard.set(id, forKey:"userID")
                    userID = id
                    withAnimation(.easeOut(duration: 0.3)) {
                        navSignUp = false
                        navSignUpConfirm = true
                    }
                } else if case .done = signUpInfo?.nextStep {
                    guard let id = signUpInfo?.userID else { throw AmplifyAuthError.signUpFailed }
                    UserDefaults.standard.set(id, forKey:"userID")
                    userID = id
                    try await createUser()
                } else {
                    throw AmplifyAuthError.signUpFailed
                }
                
            } catch let error as AmplifyAuthError {
                switch error {
                case .userAlreadyExists:
                    authErrorPopAlertProp.text = error.localizedDescription
                    authErrorPopAlertProp.isPresented = true
                    navSignIn = true
                default:
                    authErrorPopAlertProp.text = error.localizedDescription
                    authErrorPopAlertProp.isPresented = true
                }
            } catch let error {
                authErrorPopAlertProp.text = error.localizedDescription
                authErrorPopAlertProp.isPresented = true
            }
        }
        if !navSignUpConfirm, !isSignUp {
            withAnimation(.easeOut(duration: 0.3)) {
                isSignUp = true
                navHostOrGuest = true
            }
        }
    }
    
    @MainActor
    func signUpConfirmation() async throws {
        isLoading = true
        defer { isLoading = false }
        if !userName.isEmpty, !confirmationCode.isEmpty {
            do {
                signUpInfo = try await auth.confirmSignUp(for: userName + hashedKey, with: confirmationCode)
                if let signUpInfo = signUpInfo, signUpInfo.isSignUpComplete {
                    try await createUser()
                } else {
                    throw AmplifyAuthError.confirmError
                }
            } catch let error as AmplifyAuthError {
                authErrorPopAlertProp.text = error.localizedDescription
                authErrorPopAlertProp.isPresented = true
            } catch let error as AuthError {
                authErrorPopAlertProp.text = error.localizedDescription
                authErrorPopAlertProp.isPresented = true
            } catch let error {
                authErrorPopAlertProp.text = error.localizedDescription
                authErrorPopAlertProp.isPresented = true
            }
        }
    }
    
    @MainActor
    func resendCode() async throws {
        isLoading = true
        defer { isLoading = false }
        do {
            try await auth.resendSignUpCode(for: userName + hashedKey)
        } catch {
            authErrorPopAlertProp.text = APIError.createFailed.localizedDescription
            authErrorPopAlertProp.isPresented = true
        }
    }
    
    @MainActor
    func signIn() async throws {
        isLoading = true
        defer { isLoading = false }
        if !userName.isEmpty, !password.isEmpty  {
            do {
                if !asHost {
                    hashedKey = hashDelimiter + String(signUpOptions.invitedGroupID.hashed())
                    signInInfo = try await auth.signIn(username: userName + hashedKey, password: password)
                } else {
                    hashedKey = hashDelimiter + String(signUpOptions.email.hashed())
                    signInInfo = try await auth.signIn(username: userName + hashedKey, password: password)
                }
                if let signInInfo = signInInfo, signInInfo.isSignedIn {
                    let id = try await Amplify.Auth.getCurrentUser()
                    withAnimation(.easeOut(duration: 0.3)) {
                        UserDefaults.standard.set(id.userId, forKey:"userID")
                        UserDefaults.standard.set(asHost, forKey: "asHost")
                        flagInitialize()
                        DispatchQueue.main.async {
                            self.auth.isSignedIn = true
                        }
                    }
                } else if case .confirmSignUp(_) = signInInfo?.nextStep {
                    try await auth.resendSignUpCode(for: userName + hashedKey)
                    withAnimation(.easeOut(duration: 0.3)) {
                        flagInitialize()
                        navSignUpConfirm = true
                    }
                } else {
                    throw AmplifyAuthError.signInFailed
                }
            } catch let error as AmplifyAuthError {
                authErrorPopAlertProp.text = error.localizedDescription
                authErrorPopAlertProp.isPresented = true
            } catch let error as AuthError {
                authErrorPopAlertProp.text = error.localizedDescription
                authErrorPopAlertProp.isPresented = true
            }
        } else if !self.auth.isSignedIn, !isSignIn {
            withAnimation(.easeOut(duration: 0.3)) {
                isSignIn = true
                navHostOrGuest = true
            }
        }
    }
    
    @MainActor
    func createUser() async throws {
        do {
            guard let userID = UserDefaults.standard.string(forKey: "userID"), !userID.isEmpty else {
                throw AmplifyAuthError.signUpFailed
            }
            var user = User(userID: userID, userName: userName, accountType: asHost ? AccountType.host : AccountType.guest)
            if !asHost {
                user.belongingGroupIDs = [signUpOptions.invitedGroupID]
                var groupInfo = try await apiHandler.get(Group.self, byId: signUpOptions.invitedGroupID)
                if let belongingUserIDs = groupInfo.belongingUserIDs, !belongingUserIDs.isEmpty {
                    groupInfo.belongingUserIDs?.append(userID)
                } else {
                    groupInfo.belongingUserIDs = [userID]
                }
                let newList = try self.apiHandler.decodeUserDefault(modelType: [Group].self, key: "belongingGroups")?.filter({$0.id != groupInfo.id})
                apiHandler.replaceUserDefault(models: newList ?? [], keyName: "belongingGroups")
                try await apiHandler.update(groupInfo, keyName: "belongingGroups")
            }
            try await apiHandler.create(user, keyName: "User")
            withAnimation(.easeIn) {
                UserDefaults.standard.set(asHost, forKey: "asHost")
                DispatchQueue.main.async {
                    self.auth.isSignedIn = true
                }
            }
        } catch {
            authErrorPopAlertProp.text = APIError.createFailed.localizedDescription
            authErrorPopAlertProp.isPresented = true
        }
    }
    
    @MainActor
    func propertyInitialize() {
        withAnimation(.linear) {
            userName = ""
            signUpOptions.email = ""
            signUpOptions.invitedGroupID = ""
            password = ""
            confirmationCode = ""
        }
    }
    
    func flagInitialize() {
        navSignIn = false
        navSignUp = false
        navSignUpConfirm = false
        asHost = false
        navHostOrGuest = false
    }
}

struct SignUpOptions {
    var email: String = ""
    var invitedGroupID: String = ""
}
