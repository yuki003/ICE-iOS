//
//  ViewModelBase.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/09.
//

import Foundation
import SwiftUI
import Amplify

// 共通のエラーハンドリングを行うための型エイリアスを定義
typealias ErrorHandler = (Error) -> Void
typealias APIErrorHandler = (APIError) -> Void

class ViewModelBase: ObservableObject {
    @Published var state: LoadingState = .idle
    @ObservedObject var apiHandler = APIHandler()
    @ObservedObject var auth = AmplifyAuthService()
    @ObservedObject var storage = AmplifyStorageService()
    
    @Published var isLoading = false
    
    @Published var alert: Bool = false
    @Published var alertMessage: String?
    
    @Published var userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    // 非同期処理を行う共通関数
    func asyncOperation(_ operation: @escaping () async throws -> Void,
                               apiErrorHandler: @escaping APIErrorHandler,
                               errorHandler: @escaping ErrorHandler) {
        isLoading = true
        defer { isLoading = false }
        
        Task {
            do {
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