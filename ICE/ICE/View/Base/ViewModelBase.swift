//
//  ViewModelBase.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/09.
//

import Foundation
import SwiftUI
import Amplify
import Combine

// 共通のエラーハンドリングを行うための型エイリアスを定義
typealias ErrorHandler = (Error) -> Void
typealias APIErrorHandler = (APIError) -> Void

class ViewModelBase: ObservableObject {
    // MARK: Properties
    @Published var state: LoadingState = .idle
    @Published var formValid: Validation = .failed()
    @Published var userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    @Published var alertMessage: String?
    var publishers = Set<AnyCancellable>()
    let jsonDecoder = JSONDecoder()
    
    // MARK: Flags
    @Published var reload = false
    @Published var isLoading = false
    @Published var showAlert: Bool = false
    @Published var alert: Bool = false
    
    // MARK: Services
    @ObservedObject var apiHandler = APIHandler.shared
    @ObservedObject var auth = AmplifyAuthService.shared
    @ObservedObject var storage = AmplifyStorageService.shared
    @ObservedObject var apiService = APIService.shared
    @ObservedObject var enumUtil = EnumUtility.shared
    
    // 非同期処理を行う共通関数
    @MainActor
    func asyncOperation(_ operation: @escaping () async throws -> Void,
                               apiErrorHandler: @escaping APIErrorHandler,
                               errorHandler: @escaping ErrorHandler) {
        Task {
            do {
                isLoading = true
                defer { isLoading = false }
                if userID.isEmpty {
                    let userInfo = try await Amplify.Auth.getCurrentUser()
                    userID = userInfo.userId
                    UserDefaults.standard.set(userID, forKey:"userID")
                }
                try await operation()
                withAnimation(.linear) {
                    state = .loaded
                }
            } catch let error as APIError {
                apiErrorHandler(error)
                withAnimation(.linear) {
                    state = .failed(error)
                }
            } catch {
                errorHandler(error)
                withAnimation(.linear) {
                    state = .failed(error)
                }
            }
        }
    }
    
    func setErrorMessage(_ error: Error) {
        alertMessage = error.localizedDescription
        alert = true
    }
}
