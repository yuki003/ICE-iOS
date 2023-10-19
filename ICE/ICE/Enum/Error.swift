//
//  Error.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/09.
//

import Foundation

enum ConfigurationError: Error {
    case missingConfig
}

enum AmplifyAuthError {
    case signUpFailed
    case confirmError
    case signInFailed
}

extension AmplifyAuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .signUpFailed:
            return "新規登録に失敗しました。"
        case .confirmError:
            return "メールアドレス認証に失敗しました。"
        case .signInFailed:
            return "ログインに失敗しました。"
        }
    }
}
