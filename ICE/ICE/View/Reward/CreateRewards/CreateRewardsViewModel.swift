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
    @Published var frequencyAndPeriodic: FrequencyAndPeriodic = .init()
    @Published var whoGetsPaid: WhoGetsPaid = .onlyOne
    let groupID: String
    
    // MARK: Flags
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
    var frequencyAndPeriodicValidation: AnyPublisher<Validation, Never> {
        $frequencyAndPeriodic
            .map { value in
                if value.frequency == .periodic, value.periodic == nil {
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
    Publishers.CombineLatest3 (
        rewardNameValidation,
        frequencyAndPeriodicValidation,
        costValidation
    )
    .map { v1, v2, v3 in
        [v1, v2, v3].allSatisfy(\.isSuccess) ? .success : .failed()
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
            var reward = Rewards(createUserID: self.userID, rewardName: self.rewardName,description: self.rewardDescription.isEmpty ? nil : self.rewardDescription, thumbnailKey: "", frequencyType: self.frequencyAndPeriodic.frequency, whoGetsPaid: self.whoGetsPaid, cost: self.cost, groupID: self.groupID)
            if !self.image.isEmpty() {
                let key = self.groupID + reward.id
                reward.thumbnailKey = key
                try await self.storage.uploadData(self.image, key: key)
                let thumbnailURL = try await self.storage.getPublicURLForKey(key)
                reward.thumbnailKey = thumbnailURL            }
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
        frequencyAndPeriodic.frequency = .onlyOnce
        frequencyAndPeriodic.periodic = nil
        createComplete = false
    }
}
