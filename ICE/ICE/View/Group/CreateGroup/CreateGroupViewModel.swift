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
    @Published var selectedGroup: Group?
    
    init(selectedGroup: Group? = nil){
        super.init()
        self.selectedGroup = selectedGroup
        self.setGroupProperties()
        
    }
    
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
    func reLoadData() async {
        asyncOperation({ [self] in
            if let groupID = selectedGroup?.id {
                selectedGroup = try await self.apiHandler.get(Group.self, byId: groupID)
                setGroupProperties()
            }
        })
    }
    
    @MainActor
    func createGroup() async throws {
        isLoading = true
        defer { isLoading = false }
        asyncOperation({ [self] in
            showAlert = false
            var group = Group(groupName: self.groupName, description: groupDescription.isEmpty ? nil : groupDescription , thumbnailKey: "", hostUserIDs: [userID])
            let key = userID + group.id
            let url = try await storage.uploadData(image, key: key)
            group.thumbnailKey = url
            try await apiHandler.create(group, keyName: "hostGroups")
        })
    }
    
    func setGroupProperties() {
        if let group = selectedGroup {
            groupName = group.groupName
            groupDescription = group.description ?? ""
            if let thumbnailKey = group.thumbnailKey {
                image = UIImage(url: thumbnailKey)
            }
        }
    }
}
