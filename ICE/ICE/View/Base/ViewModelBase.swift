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
    @Published var asHost: Bool = UserDefaults.standard.bool(forKey: "asHost")
    @Published var alertMessage: String?
    @Published var apiErrorPopAlertProp: PopupAlertProperties = .init(title: "操作エラー", text: "操作をやり直してください。")
    var publishers = Set<AnyCancellable>()
    let jsonDecoder = JSONDecoder()
    
    // MARK: Flags
    @Published var reload = false
    @Published var isLoading = false
    @Published var showAlert: Bool = false
    @Published var ErrorAlert: Bool = false
    
    // MARK: Services
    @ObservedObject var apiHandler = APIHandler.shared
    @ObservedObject var auth = AmplifyAuthService.shared
    @ObservedObject var storage = AmplifyStorageService.shared
    @ObservedObject var apiService = APIService.shared
    @ObservedObject var enumUtil = EnumUtility.shared
    
    // 非同期処理を行う共通関数
    @MainActor
    func asyncOperation(_ operation: @escaping () async throws -> Void,
                        apiErrorHandler: @escaping APIErrorHandler = {_ in },
                        errorHandler: @escaping ErrorHandler = {_ in }) {
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
                
                if reload {
                    reload = false
                }
                
                withAnimation(.linear) {
                    state = .loaded
                }
            } catch let error as APIError {
                apiErrorHandler(error)
                apiErrorPopAlertProp.text = error.localizedDescription
                apiErrorPopAlertProp.isPresented = true
                
//                withAnimation(.linear) {
//                    state = .failed(error)
//                }
            } catch {
                errorHandler(error)
                apiErrorPopAlertProp.text = error.localizedDescription
                apiErrorPopAlertProp.isPresented = true
//                withAnimation(.linear) {
//                    state = .failed(error)
//                }
            }
        }
    }
    
    func setErrorMessage(_ error: Error) {
        alertMessage = error.localizedDescription
        ErrorAlert = true
    }
}
