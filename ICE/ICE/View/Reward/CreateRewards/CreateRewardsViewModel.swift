//
//  CreateRewardsViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/12/13.
//

import SwiftUI
import Amplify
import Combine

final class CreateRewardsViewModel: ViewModelBase {
    // MARK: Properties
    @Published var image = UIImage()
    @Published var rewardName: String = ""
    @Published var rewardDescription: String = ""
    @Published var thumbnailKey: String?
    @Published var cost: Int = 0
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var frequencyType: FrequencyType = .onlyOnce
    @Published var whoGetsPaid: WhoGetsPaid = .onlyOne
    @Published var selectedReward: Rewards?
    let groupID: String
    
    // MARK: Flags
    @Published var isLimited: Bool = false
    @Published var showImagePicker: Bool = false
    var isEdit: Bool {
        selectedReward != nil
    }
    
    // MARK: Instances
    
    @Published var confirmRewardAlertProp: PopupAlertProperties = .init()
    var confirmTitle: String {
        isEdit ? "編集しますか？" :  "作成しますか？"
    }
    
    var confirmText: String {
        isEdit ? editText  : createText
    }
    let createText = """
                     入力した内容でリワードを作成します。
                     作成したリワードはのちに編集することもできます。
                     """
    let editText = """
                   入力した内容でリワードを作成します。
                   作成したリワードはのちに編集することもできます。
                   """
    let deleteText = """
                   リワードを削除します。
                   削除したリワードは元に戻すことができません。
                   """
    
    var completeTitle: String {
        isEdit ? "編集完了!!" : "作成完了!!"
    }
    
    var completeText: String {
        isEdit ? completeEdit : completeCreate
    }
    
    let completeCreate = "グループ画面から作ったリワードを確認できます。"
    let completeEdit = "グループ画面から編集したリワードを確認できます。"
    let completeDelete = "リワードを削除しました。"
    
    @Published var completeRewardAlertProp: PopupAlertProperties = .init()
    
    // MARK: Validations
    var rewardNameValidation: AnyPublisher<Validation, Never> {
        $rewardName
            .dropFirst()
            .map { value in
                if value.isEmpty {
                    return .failed()
                }
                return .success
            }
            .eraseToAnyPublisher()
    }
    
    var costValidation: AnyPublisher<Validation, Never> {
        $cost
            .dropFirst()
            .map { value in
                if value == 0 {
                    return .failed()
                }
                if value < 0 {
                    return .failed(message: "マイナス値は設定できません")
                }
                return .success
            }
            .eraseToAnyPublisher()
    }

var createValidation: AnyPublisher<Validation, Never> {
    Publishers.CombineLatest (
        rewardNameValidation,
        costValidation
    )
    .map { v1, v2 in
        [v1, v2].allSatisfy(\.isSuccess) ? .success : .failed()
    }
    .eraseToAnyPublisher()
}
    
    // MARK: initializer
    init(groupID: String, selectedReward: Rewards? = nil)
    {
        self.groupID = groupID
        self.selectedReward = selectedReward
        super.init()
        self.createValidation
            .receive(on: RunLoop.main)
            .assign(to: \.formValid, on: self)
            .store(in: &publishers)
        confirmRewardAlertProp.text = confirmText
        confirmRewardAlertProp.title = confirmTitle
        completeRewardAlertProp.text = completeText
        completeRewardAlertProp.title = completeTitle
    }
    @MainActor
    func loadData() {
        if let selected = selectedReward {
            rewardName = selected.rewardName
            rewardDescription = selected.description ?? ""
            thumbnailKey = selected.thumbnailKey ?? ""
            frequencyType = selected.frequencyType
            whoGetsPaid = selected.whoGetsPaid
            cost = selected.cost
        }
    }
    @MainActor
    func createReward() async throws {
        asyncOperation({ [self] in
            isLoading = true
            defer { isLoading = false }
            confirmRewardAlertProp.isPresented = false
            var reward: Rewards
            
            if let selected = selectedReward {
                reward = selected
                reward.rewardName = rewardName
                reward.description = rewardDescription
                reward.thumbnailKey = thumbnailKey
                reward.frequencyType = frequencyType
                reward.whoGetsPaid = whoGetsPaid
                reward.cost = cost
                if isLimited {
                    reward.startDate = Temporal.DateTime(startDate)
                    reward.endDate = Temporal.DateTime(endDate)
                }
                try await uploadRewordImage(reward)
                try await apiHandler.update(reward, keyName: "\(groupID)-rewards")
            } else {
                reward = Rewards(createUserID: userID, rewardName: rewardName,description: rewardDescription.isEmpty ? nil : rewardDescription, thumbnailKey: "", frequencyType: frequencyType, whoGetsPaid: whoGetsPaid, cost: cost, groupID: groupID)
                
                if isLimited {
                    reward.startDate = Temporal.DateTime(startDate)
                    reward.endDate = Temporal.DateTime(endDate)
                }
                
                try await uploadRewordImage(reward)
                try await apiHandler.create(reward, keyName: "\(groupID)-rewards")
            }
            
            completeRewardAlertProp.action = initialization
            completeRewardAlertProp.isPresented = true
        })
    }
    
    func uploadRewordImage(_ reward: Rewards) async throws {
        if !image.isEmpty() {
            let key = groupID + reward.id
            guard let url = try await storage.uploadData(image, key: key) else {
                throw AmplifyStorageError.uploadFailed
            }
            thumbnailKey = url
        }
    }
    @MainActor
    func deleteRewards() async throws {
        asyncOperation({ [self] in
            isLoading = true
            defer { isLoading = false }
            guard let key = selectedReward?.thumbnailKey else {
                throw AmplifyStorageError.uploadFailed
            }
            try await storage.deleteData(key: key)
            try await apiHandler.delete(selectedReward!, keyName: "\(groupID)-rewards")
            completeRewardAlertProp.action = initialization
            completeRewardAlertProp.isPresented = true
        })
    }
    
    @MainActor
    func initialization() {
        rewardName = ""
        rewardDescription = ""
        thumbnailKey = ""
        cost = 0
        frequencyType = .onlyOnce
    }
}
