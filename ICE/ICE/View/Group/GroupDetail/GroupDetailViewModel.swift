//
//  GroupDetailViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/18.
//

import SwiftUI
import Amplify

final class GroupDetailViewModel: ViewModelBase {
    @Published var text: String = ""
    @Published var num: Int = 0
    @Published var groupInfo: Group
    @Published var users: [User] = []
    @Published var selectedUser: User?
    @Published var selectedTask: Tasks?
    var invitationBaseText: String { """
「ICE」アプリのグループ「\(groupInfo.groupName)」からの招待状です！
グループのミッションを達成してポイントをゲット！
貯めたポイントを使ってリワードをもらおう！
Link： ice://invite?code=\(groupInfo.id)
"""
    }
    var displayUser: [User] {
        Array(users.prefix(5))
    }
    var notDisplayUserCount: Int {
        users.count - displayUser.count
    }
    
    @Published var tasks: [Tasks] = []
    var latestTasks: [Tasks] {
        Array(tasks.sorted(by: { $0.updatedAt?.foundationDate ?? Date() > $1.updatedAt?.foundationDate ?? Date() }).prefix(3))
    }
    
    @Published var rewards: [Rewards] = []
    var latestRewards: [Rewards] {
        Array(rewards.sorted(by: { $0.createdAt?.foundationDate ?? Date() > $1.createdAt?.foundationDate ?? Date()}).prefix(3))
    }
    
    init(groupInfo: Group) {
        self.groupInfo = groupInfo
    }
    
    @MainActor
    func loadData() async throws {
        asyncOperation({
            if self.apiHandler.isRunFetch(userDefaultKey: "\(self.groupInfo.id)-users") || self.reload {
                var userIDs:[String?] = []
                if let hostUserIDs = self.groupInfo.hostUserIDs {
                    userIDs.append(contentsOf: hostUserIDs)
                }
                if let belongingUserIDs = self.groupInfo.belongingUserIDs {
                    userIDs.append(contentsOf: belongingUserIDs)
                }
                let userPredicate = self.apiService.orPredicateGroupByID(ids: userIDs, model: User.keys.userID)
                if let predicate = userPredicate {
                    let users = try await self.apiHandler.list(User.self, where: predicate, keyName: "\(self.groupInfo.id)-users")
                    self.users = users.sorted(by: {$0.createdAt! > $1.createdAt!})
                }
            } else {
                self.users = try self.apiHandler.decodeUserDefault(modelType: [User].self, key: "\(self.groupInfo.id)-users") ?? []
            }
            
            if self.apiHandler.isRunFetch(userDefaultKey: "\(self.groupInfo.id)-tasks") || self.reload {
                let tasksPredicate = self.apiService.orPredicateGroupByID(ids: self.groupInfo.taskIDs ?? [], model: Tasks.keys.id)
                if let predicate = tasksPredicate {
                    let tasks = try await self.apiHandler.list(Tasks.self, where: predicate, keyName: "\(self.groupInfo.id)-tasks")
                    self.tasks = tasks.sorted(by: {$0.createdAt! > $1.createdAt!})
                }
            } else {
                self.tasks = try self.apiHandler.decodeUserDefault(modelType: [Tasks].self, key: "\(self.groupInfo.id)-tasks") ?? []
            }
            
            if self.apiHandler.isRunFetch(userDefaultKey: "\(self.groupInfo.id)-rewards") || self.reload {
                let rewardsPredicate = self.apiService.orPredicateGroupByID(ids: self.groupInfo.rewardIDs ?? [], model: Rewards.keys.id)
                if let predicate = rewardsPredicate {
                    let rewards = try await self.apiHandler.list(Rewards.self, where: predicate, keyName: "\(self.groupInfo.id)-rewards")
                    self.rewards = rewards.sorted(by: {$0.createdAt! > $1.createdAt!})
                }
            } else {
                self.rewards = try self.apiHandler.decodeUserDefault(modelType: [Rewards].self, key: "\(self.groupInfo.id)-rewards") ?? []
            }
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
    
    @MainActor
    func reloadData() async throws {
        do {
            let predicate = Group.keys.id.eq(self.groupInfo.id)
            let groupInfo = try await self.apiHandler.list(Group.self, where: predicate, keyName: "belongingGroups")
            self.groupInfo = groupInfo[0]
            try await loadData()
        } catch {
            alertMessage = error.localizedDescription
            alert = true
        }
    }
    
    @MainActor
    func tryTask() async throws {
        asyncOperation({
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
}
