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
    func uploadData(_ image: UIImage, key: String) async throws {
        guard let jpegData = image.jpegData(compressionQuality: 0.5) else { return }
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
        print("Completed: \(value)")
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
}
