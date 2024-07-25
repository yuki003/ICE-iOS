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
    @Published var cost: Int = 0
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var frequencyType: FrequencyType = .onlyOnce
    @Published var whoGetsPaid: WhoGetsPaid = .onlyOne
    let groupID: String
    
    // MARK: Flags
    @Published var isLimited: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var createComplete: Bool = false
    
    // MARK: Instances
    
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
    init(groupID: String)
    {
        self.groupID = groupID
        super.init()
        self.createValidation
            .receive(on: RunLoop.main)
            .assign(to: \.formValid, on: self)
            .store(in: &publishers)
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
    func createReward() async throws {
        asyncOperation({
            self.showAlert = false
            var reward = Rewards(createUserID: self.userID, rewardName: self.rewardName,description: self.rewardDescription.isEmpty ? nil : self.rewardDescription, thumbnailKey: "", frequencyType: self.frequencyType, whoGetsPaid: self.whoGetsPaid, cost: self.cost, groupID: self.groupID)
            
            if self.isLimited {
                reward.startDate = Temporal.DateTime(self.startDate)
                reward.endDate = Temporal.DateTime(self.endDate)
            }
            
            if !self.image.isEmpty() {
                let key = self.groupID + reward.id
                let url = try await self.storage.uploadData(self.image, key: key)
                reward.thumbnailKey = url
            }
            
            try await self.apiHandler.create(reward, keyName: "\(self.groupID)-rewards")
            self.createComplete = true
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
    
    @MainActor
    func initialization() {
        rewardName = ""
        rewardDescription = ""
        cost = 0
        frequencyType = .onlyOnce
        createComplete = false
    }
}
