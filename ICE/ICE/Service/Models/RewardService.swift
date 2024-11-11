//
//  RewardService.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/09/28.
//

import Foundation
import SwiftUI

final class RewardService: ViewModelBase {
    @Published var selectedReward: Rewards?
    @Published var appliedUserList: [User] = []
    @Published var navToApplyReward: Bool = false
    @Published var navToRewardsList: Bool = false
    @Published var navToRewardInsight: Bool = false
    @Published var navToHostRewardsActions: Bool = false
    @Published var navToRewardApply: Bool = false
    @Published var applyConfirmAlertProp: PopupAlertProperties = .init(title:"このリワードを獲得しますか？")
    @Published var applyRejectAlertProp: PopupAlertProperties = .init(title:"ポイントが不足しています")
    @Published var applyCancelAlertProp: PopupAlertProperties = .init(title:"リワードの申請を取り消しますか？")
    @Published var rewardAppliedAlertProp: PopupAlertProperties = .init(title: "リワードを申請しました！", text: "申請が承認されたらリワードを受け取ろう！")
    @Published var rewardCanceledAlertProp: PopupAlertProperties = .init(title: "申請を取り消しました！")
    
    override init() {
        super.init()
    }
    
    // MARK: API Action
    @MainActor
    func applyRewardOrder(groupID: String) async throws {
        asyncOperation({ [self] in
            if let selectedReward = selectedReward {
                var selectedReward = selectedReward
                if let appliedUserID = selectedReward.appliedUserIDs, !appliedUserID.contains(where: { $0 == userID}) {
                    selectedReward.appliedUserIDs?.append(userID)
                } else {
                    selectedReward.appliedUserIDs = [userID]
                }
                try await apiHandler.update(selectedReward, keyName: "\(groupID)-rewards")
            }
            rewardAppliedAlertProp.isPresented = true
        })
    }
    
    @MainActor
    func reApplyRewardOrder(groupID: String) async throws {
        asyncOperation({ [self] in
            if let selectedReward = selectedReward {
                var selectedReward = selectedReward
                selectedReward.rejectedUserIDs?.removeAll(where: {$0 == userID})
                if let appliedUserID = selectedReward.appliedUserIDs, !appliedUserID.contains(where: { $0 == userID}) {
                    selectedReward.appliedUserIDs?.append(userID)
                } else {
                    selectedReward.appliedUserIDs = [userID]
                }
                try await apiHandler.update(selectedReward, keyName: "\(groupID)-rewards")
            }
            rewardAppliedAlertProp.isPresented = true
        })
    }
    
    @MainActor
    func applyCancelOrder(groupID: String) async throws {
        asyncOperation({ [self] in
            if let selectedReward = selectedReward {
                var selectedReward = selectedReward
                if let appliedUserID = selectedReward.appliedUserIDs, appliedUserID.contains(where: { $0 == userID}) {
                    selectedReward.appliedUserIDs?.removeAll(where: { $0 == userID})
                } else {
                    throw APIError.updateFailed
                }
                try await apiHandler.update(selectedReward, keyName: "\(groupID)-rewards")
            }
            rewardCanceledAlertProp.isPresented = true
        })
    }
    
    // MARK: View Builder
    @ViewBuilder
    func rewardListBuilder(_ rewardList:[Rewards], _ selected: Binding<Rewards?>, _ navTo: Binding<Bool>, _ point: Int) -> some View {
        ForEach(rewardList.indices, id: \.self) { index in
            let reward = rewardList[index]
            let status = RewardStatus.init(reward)
            PendingRewardRow(reward: reward, selected: selected, navTo: navTo,
                             action: {
                // apply action for guest
                if status == .applied {
                    self.selectedReward = reward
                    self.applyCancelAlertProp.action = {try await self.applyCancelOrder(groupID: reward.groupID)}
                    self.applyCancelAlertProp.isPresented = true
                } else {
                    if point >= reward.cost {
                        self.selectedReward = reward
                        if status == .none {
                            self.applyConfirmAlertProp.action = {try await self.applyRewardOrder(groupID: reward.groupID)}
                        } else if status == .rejected {
                            self.applyConfirmAlertProp.action = {try await self.reApplyRewardOrder(groupID: reward.groupID)}
                        }
                        self.applyConfirmAlertProp.isPresented = true
                    } else {
                        self.applyRejectAlertProp.isPresented = true
                    }
                }
            }, status: status)
            .padding(.leading, 10)
        }
    }
}
