//
//  AmplifyStorageService.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/08.
//

import Foundation
import Amplify

class AmplifyStorageService: ObservableObject {
    func uploadData() async throws {
        let dataString = "Example file contents"
        let data = Data(dataString.utf8)
        let uploadTask = Amplify.Storage.uploadData(
            key: "ExampleKey",
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
}
