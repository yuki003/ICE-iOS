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
    func loadData() async {
        asyncOperation({ [self] in
            if apiHandler.isRunFetch(userDefaultKey: "\(groupInfo.id)-users") || reload {
                var userIDs:[String?] = []
                if let hostUserIDs = groupInfo.hostUserIDs {
                    userIDs.append(contentsOf: hostUserIDs)
                }
                if let belongingUserIDs = groupInfo.belongingUserIDs {
                    userIDs.append(contentsOf: belongingUserIDs)
                }
                let userPredicate = apiService.orPredicateGroupByID(ids: userIDs, model: User.keys.userID)
                if let predicate = userPredicate {
                    let users = try await apiHandler.list(User.self, where: predicate, keyName: "\(groupInfo.id)-users")
                    self.users = users.sorted(by: {$0.createdAt! > $1.createdAt!})
                }
            } else {
                self.users = try apiHandler.decodeUserDefault(modelType: [User].self, key: "\(groupInfo.id)-users") ?? []
            }
            
            if apiHandler.isRunFetch(userDefaultKey: "\(groupInfo.id)-tasks") || reload {
                let tasksPredicate = apiService.orPredicateGroupByID(ids: groupInfo.taskIDs ?? [], model: Tasks.keys.id)
                if let predicate = tasksPredicate {
                    let tasks = try await apiHandler.list(Tasks.self, where: predicate, keyName: "\(groupInfo.id)-tasks")
                    self.tasks = tasks.sorted(by: {$0.createdAt! > $1.createdAt!})
                }
            } else {
                self.tasks = try apiHandler.decodeUserDefault(modelType: [Tasks].self, key: "\(groupInfo.id)-tasks") ?? []
            }
            
            if apiHandler.isRunFetch(userDefaultKey: "\(groupInfo.id)-rewards") || reload {
                let rewardsPredicate = apiService.orPredicateGroupByID(ids: groupInfo.rewardIDs ?? [], model: Rewards.keys.id)
                if let predicate = rewardsPredicate {
                    let rewards = try await apiHandler.list(Rewards.self, where: predicate, keyName: "\(groupInfo.id)-rewards")
                    self.rewards = rewards.sorted(by: {$0.createdAt! > $1.createdAt!})
                }
            } else {
                self.rewards = try apiHandler.decodeUserDefault(modelType: [Rewards].self, key: "\(groupInfo.id)-rewards") ?? []
            }
        })
    }
    
    @MainActor
    func reloadData() async throws {
        do {
            let predicate = Group.keys.id.eq(groupInfo.id)
            let groupInfo = try await apiHandler.list(Group.self, where: predicate, keyName: "belongingGroups")
            self.groupInfo = groupInfo[0]
            await loadData()
        } catch {
            alertMessage = error.localizedDescription
            ErrorAlert = true
        }
    }
}
