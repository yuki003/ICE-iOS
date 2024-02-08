//
//  AmplifyStorageService.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/08.
//

import Foundation
import SwiftUI
import Amplify

class AmplifyStorageService: ObservableObject {
    static let shared = AmplifyStorageService()
    var userDefaultKeys: [String] = []
    let defaults = UserDefaults.standard
    func uploadData(_ image: UIImage, key: String) async throws -> String? {
        guard let jpegData = image.jpegData(compressionQuality: 0.5) else { return nil }
        let data = Data(jpegData)
        let uploadTask = Amplify.Storage.uploadData(
            key: key,
            data: data
        )
        Task {
            for await progress in await uploadTask.progress {
                print("Progress: \(progress)")
            }
        }
        let value = try await uploadTask.value
        
//        appendImageUserDefault(image: image, keyName: "")
        print("Completed: \(value)")
        
        let publicURL = try await getPublicURLForKey(key)
        
        let url = publicURL.cutOutBefore(keyword: key)
        
        return url
    }
    
    func getPublicURLForKey(_ key: String) async throws -> String {
        let url = try await Amplify.Storage.getURL(key: key)
        return url.absoluteString
    }

    
    func downloadData(key: String) async throws -> Data {
        let downloadTask = Amplify.Storage.downloadData(key: key)
        Task {
            for await progress in await downloadTask.progress {
                print("Progress: \(progress)")
            }
        }
        let data = try await downloadTask.value
        print("Completed: \(data)")
        return data
    }
    
    func downloadImage(key: String?) async throws -> UIImage {
        if let key = key {
            let data = try await downloadData(key: key)
            let image = UIImage(data: data) ?? UIImage()
            return image
        } else {
            return UIImage()
        }
    }
    
    func deleteData(key: String) async throws {
        do {
            let removedKey = try await Amplify.Storage.remove(key: key)
            print("Deleted \(removedKey)")
        } catch  let error as StorageError {
            switch error {
            case .configuration(_, _, _):
                print("configuration exception")
                print(error)
            case .service(let description, _, _):
                print("service exception")
                print(error)
                if description.contains("Invalid verification code"){
                    throw AmplifyAuthError.notAuthorized
                }
            case .unknown(_, _):
                print("unknown exception")
                print(error)
            case .validation(_, _, _, _):
                print("validation exception")
                print(error)
            case .accessDenied(_, _, _):
                print("configuration exception")
                print(error)
            case .authError(_, _, _):
                print("configuration exception")
                print(error)
            case .httpStatusError(_, _, _):
                print("configuration exception")
                print(error)
            case .keyNotFound(_, _, _, _):
                print("configuration exception")
                print(error)
            case .localFileNotFound(_, _, _):
                print("configuration exception")
                print(error)
            }
            print("An error occurred while confirming sign up \(error)")
            throw error
        }
    }
//
//    func appendImageUserDefault(image: UIImage, keyName: String) {
//        // 新しい画像をDataに変換
//        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
//            print("Failed to convert image to Data")
//            return
//        }
//
//        // UserDefaultsから既存の画像データ配列を取得
//        var imageDataArray: [Data]
//        if let existingImageDataArray = defaults.object(forKey: keyName) as? [Data] {
//            imageDataArray = existingImageDataArray
//        } else {
//            imageDataArray = []
//        }
//
//        // 新しい画像データを配列に追加
//        imageDataArray.append(imageData)
//
//        // 更新された画像データ配列をUserDefaultsに保存
//        defaults.set(imageDataArray, forKey: keyName)
//        if !userDefaultKeys.contains(where: { value in
//            value == keyName
//        }) {
//            userDefaultKeys.append(keyName)
//        }
//    }
//    
//    func setImagesUserDefault(images: [UIImage], keyName: String) {
//        let imageDataArray = images.compactMap { $0.jpegData(compressionQuality: 1.0) ?? nil }
//        
//        defaults.set(imageDataArray, forKey: keyName)
//        if !userDefaultKeys.contains(where: { value in
//            value == keyName
//        }) {
//            userDefaultKeys.append(keyName)
//        }
//    }
//    
//    func decodeImagesUserDefaults(keyName: String) -> [UIImage]? {
//        guard let imageDataArray = defaults.object(forKey: keyName) as? [Data] else {
//            return nil
//        }
//        
//        return imageDataArray.compactMap { UIImage(data: $0) }
//    }
//    
//    func isRunFetchImage(userDefaultKey: String) -> Bool {
//        print(userDefaultKeys)
//        return !userDefaultKeys.contains(userDefaultKey)
//    }
}
