//
//  CreateGroupViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/31.
//


import SwiftUI
import Amplify
import Combine

final class CreateGroupViewModel: ViewModelBase {
    @Published var buttonDisabled: Bool = false
    
    @Published var createGroup: Bool = false
    @Published var belongGroup: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var image = UIImage()
    @Published var groupName: String = ""
    @Published var groupDescription: String = ""
    
    var groupNameValidation: AnyPublisher<Validation, Never> {
        $groupName
            .dropFirst()
            .map { value in
                if value.isEmpty {
                    return .failed()
                }
                return .success
            }
            .eraseToAnyPublisher()
    }
    var thumbnailValidation: AnyPublisher<Validation, Never> {
        $image
            .map { value in
                if value.size == CGSize.zero {
                    return .failed(message: "サムネイルの設定は任意です")
                }
                return .success
            }
            .eraseToAnyPublisher()
    }
    
    @MainActor
    func loadData() async throws {
        asyncOperation({
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
    
    @MainActor
    func createGroup() async throws {
        asyncOperation({
            self.showAlert = false
            var group = Group(groupName: self.groupName, description: self.groupDescription.isEmpty ? nil : self.groupDescription , thumbnailKey: "", hostUserIDs: [self.userID])
            let key = self.userID + group.id
            let url = try await self.storage.uploadData(self.image, key: key)
            group.thumbnailKey = url
            try await self.apiHandler.create(group, keyName: "hostGroups")
        })
    }
}
