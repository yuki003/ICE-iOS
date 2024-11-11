//
//  RewardApprovalViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/10/21.
//

import SwiftUI
import Amplify
import Combine

final class RewardApprovalViewModel: ViewModelBase {
    // MARK: Instances
    @Published var image = UIImage()
    @Published var selectedUserID: String = ""
    @Published var reward: Rewards
    @Published var appliedUserList: [User] = []
    @Published var approvedAlertProp: PopupAlertProperties = .init(title: "承認完了！", text: "リワードを与えて感謝を伝えましょう！")
    @Published var rejectedAlertProp: PopupAlertProperties = .init(title: "却下しました")
    @Published var approveConfirmAlertProp: PopupAlertProperties = .init(title: "リワード申請を承認しますか？",
                                                                  text: """
                                                                        承認後は必ず指定したリワードを申請者に与えてください。
                                                                        
                                                                        """)
    @Published var rejectConfirmAlertProp: PopupAlertProperties = .init(title: "リワード申請を却下しますか？")
    
    // MARK: initializer
    init(reward: Rewards)
    {
        self.reward = reward
    }
    @MainActor
    func loadData() async {
        asyncOperation({ [self] in
            if let appliedUserIDs = reward.appliedUserIDs, !appliedUserIDs.isEmpty {
                let userPredicates = apiService.orPredicateGroupByID(ids: appliedUserIDs, model: userKeys.userID)
                appliedUserList = try await apiHandler.list(User.self, where: userPredicates)
            }
            if let thumbnailKey = reward.thumbnailKey, thumbnailKey.isNotEmpty {
                image = fetchImages(reward.thumbnailKey)[0]
            }
        })
    }
    
    @MainActor
    func rejectReward() async throws {
        asyncOperation({ [self] in
            isLoading = true
            defer { isLoading = false }
            var rewardsModel: Rewards
            rewardsModel = reward
            rewardsModel.appliedUserIDs?.removeAll(where: {$0 == selectedUserID})
            if let rejectedUserIDs = rewardsModel.rejectedUserIDs, !rejectedUserIDs.isEmpty {
                rewardsModel.rejectedUserIDs?.append(selectedUserID)
            } else {
                rewardsModel.rejectedUserIDs = [selectedUserID]
            }
            rewardsModel.appliedUserIDs?.removeAll(where: {$0 == selectedUserID})
            try await apiHandler.update(rewardsModel)
            rejectedAlertProp.isPresented = true
        })
    }
    
    @MainActor
    func approveReward() async {
        asyncOperation({ [self] in
            isLoading = true
            defer { isLoading = false }
            var rewardsModel: Rewards
                rewardsModel = reward
                rewardsModel.appliedUserIDs?.removeAll(where: {$0 == selectedUserID})
                if let getUserID = rewardsModel.getUserID, !getUserID.isEmpty {
                    rewardsModel.getUserID?.append(selectedUserID)
                } else {
                    rewardsModel.getUserID = [selectedUserID]
                }
                
                try await apiHandler.update(rewardsModel)
            approvedAlertProp.isPresented = true
        })
    }
    
    // MARK: Property Function
    func approveRewardAction() {
        approveConfirmAlertProp.action = approveReward
        approveConfirmAlertProp.isPresented = true
    }
    
    func rejectRewardAction() {
        rejectConfirmAlertProp.action = rejectReward
        rejectConfirmAlertProp.isPresented = true
    }
    
    func fetchImages(_ urlList: String?...) -> [UIImage] {
        var images: [UIImage?] = []
        for url in urlList {
            if let url = url {
                images.append(UIImage(url: url))
            }
        }
        return images.compactMap{ $0 }
    }
}
