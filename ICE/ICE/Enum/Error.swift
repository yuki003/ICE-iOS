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
enum APIError: Error {
    case notFound
    case userIdNotExists
    case createFailed
    case updateFailed
    case deleteFailed
}
extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "データが見つかりませんでした"
        case .userIdNotExists:
            return "ユーザー情報が見つかりません。ログインし直してください。"
        case .createFailed:
            return "登録に失敗しました"
        case .updateFailed:
            return "更新に失敗しました。"
        case .deleteFailed:
            return "削除に失敗しました。"
        }
    }
}
enum AmplifyAuthError {
    case signUpFailed
    case confirmError
    case signInFailed
    case signOutFailed
    case userDoesNotExists
    case userAlreadyExists
    case notAuthorized
    case invalidVerificationCode
    case alreadyConfirmed
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
        case .signOutFailed:
            return "ログアウトに失敗しました。"
        case .userAlreadyExists:
            return "指定のユーザーはすでに存在しています。"
        case .userDoesNotExists:
            return "指定のユーザーが見つかりません。"
        case .notAuthorized:
            return "認証できませんでした。入力内容をお確かめください。"
        case .invalidVerificationCode:
            return "認証コードが間違っています。"
        case .alreadyConfirmed:
            return "ユーザーはすでに認証済みです。ログイン操作を行なってください。"
        }
    }
}

enum AmplifyStorageError: Error {
    case uploadFailed
}
extension AmplifyStorageError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .uploadFailed:
            return "画像アップロードに失敗しました。"
        }
    }
}
enum DeveloperError {
    case userDefaultKeyDuplicated
}
extension DeveloperError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .userDefaultKeyDuplicated:
            return "ユーザーデフォルト取得に使ったkeyが重複しています。"
        }
    }
}
