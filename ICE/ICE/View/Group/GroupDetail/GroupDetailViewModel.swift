//
//  GroupDetailViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/18.
//

import SwiftUI
import Amplify

final class GroupDetailViewModel: ViewModelBase {
    @Published var createTask: Bool = false
    @Published var createReward: Bool = false
    @Published var text: String = ""
    @Published var num: Int = 0
    @Published var groupInfo: Group
    @Published var thumbnail: UIImage
    @Published var users: [User] = []
    @Published var userThumbnails: [UIImage] = []
    @Published var selectedUser: User?
    var displayUser: [User] {
        Array(users.prefix(5))
    }
    var notDisplayUserCount: Int {
        users.count - displayUser.count
    }
    
    @Published var tasks: [Tasks] = []
    var latestTasks: [Tasks] {
        Array(tasks.sorted(by: { $0.updatedAt!.foundationDate > $1.updatedAt!.foundationDate }).prefix(3))
    }
    
    @Published var rewards: [Rewards] = []
    var latestRewards: [Rewards] {
        Array(rewards.sorted(by: { $0.createdAt!.foundationDate > $1.createdAt!.foundationDate}).prefix(3))
    }
    
    init(groupInfo: Group, thumbnail: UIImage) {
        self.groupInfo = groupInfo
        self.thumbnail = thumbnail
    }
    
    @MainActor
    func loadData() async throws {
        asyncOperation({
            var userIDs:[String?] = []
            if let hostUserIDs = self.groupInfo.hostUserIDs {
                userIDs.append(contentsOf: hostUserIDs)
            }
            if let belongingUserIDs = self.groupInfo.belongingUserIDs {
                userIDs.append(contentsOf: belongingUserIDs)
            }
            
            // 検証中のAPIアクセスを節約するためにコメントアウト＆スタブを導入
            self.users = [User(userID: "7adf414e-d90b-47db-bd1b-b2b9155aafbe", userName: "Yuki", accountType: AccountType(rawValue: "HOST")!),
                          User(userID: "7adf414e-d90b-47db-bd1b-b2b9155aafbe", userName: "Yuki", accountType: AccountType(rawValue: "HOST")!)]
            self.userThumbnails = [UIImage(), UIImage()]
            self.tasks = [Tasks(createUserID: "7adf414e-d90b-47db-bd1b-b2b9155aafbe", taskName: "First Task", description: "I will complete developing this app!", iconName: "Programing", frequencyType: FrequencyType.onlyOnce, point: 10000, updatedAt: Temporal.DateTime(Date())),
                          Tasks(createUserID: "7adf414e-d90b-47db-bd1b-b2b9155aafbe", taskName: "Task2", frequencyType: FrequencyType.periodic, point: 10, updatedAt: Temporal.DateTime(Date()))]
            self.rewards = [Rewards(createUserID: "7adf414e-d90b-47db-bd1b-b2b9155aafbe", rewardName: "Reward1", frequencyType: FrequencyType.onlyOnce, whoGetsPaid: WhoGetsPaid.onlyOne, cost: 100, createdAt: Temporal.DateTime(Date())),
                            Rewards(createUserID: "7adf414e-d90b-47db-bd1b-b2b9155aafbe", rewardName: "Reward2", frequencyType: FrequencyType.periodic, periodicType: PeriodicType.oncePerWeek ,whoGetsPaid: WhoGetsPaid.onlyOne, cost: 1000, createdAt: Temporal.DateTime(Date())),
                            Rewards(createUserID: "7adf414e-d90b-47db-bd1b-b2b9155aafbe", rewardName: "Reward3", frequencyType: FrequencyType.onlyOnce, whoGetsPaid: WhoGetsPaid.onlyOne, cost: 20, createdAt: Temporal.DateTime(Date())),
                            Rewards(createUserID: "7adf414e-d90b-47db-bd1b-b2b9155aafbe", rewardName: "Reward4", frequencyType: FrequencyType.onlyOnce, whoGetsPaid: WhoGetsPaid.onlyOne, cost: 1000, createdAt: Temporal.DateTime(Date()))]
            
            var userPredicate: QueryPredicateGroup = .init()
            for id in userIDs {
                userPredicate = userPredicate.or(User.keys.userID.eq(id))
            }
//            let userPredicate = self.apiService.orPredicateGroupByID(ids: userIDs, model: User.keys.userID)
//            let tasksPredicate = self.apiService.orPredicateGroupByID(ids: self.groupInfo.taskIDs ?? [], model: Tasks.keys.id)
//            let rewardsPredicate = self.apiService.orPredicateGroupByID(ids: self.groupInfo.rewardIDs ?? [], model: Rewards.keys.id)
//            
//            if let predicate = userPredicate {
//                let users = try await self.apiHandler.list(User.self, where: predicate)
//                self.users = users
//            }
//            if let predicate = tasksPredicate {
//                let tasks = try await self.apiHandler.list(Tasks.self, where: predicate)
//                self.tasks = tasks
//            }
//            if let predicate = rewardsPredicate {
//                let rewards = try await self.apiHandler.list(Rewards.self, where: predicate)
//                self.rewards = rewards
//            }
//            
//            for user in self.users {
//                let thumbnail = try await self.storage.downloadImage(key: user.thumbnailKey)
//                self.userThumbnails.append(thumbnail)
//            }
            
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
    
    @MainActor
    func reloadData() async throws {
        asyncOperation({
            
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
}
