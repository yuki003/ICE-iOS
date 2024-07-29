//
//  HomeViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/23.
//

import SwiftUI
import Amplify

final class HomeViewModel: ViewModelBase {
    @Published var userInfo: User?
    @Published var hostGroups: [Group]?
    @Published var belongingGroups: [Group]?
    @Published var selectedGroup: Group?
    
    @Published var isShowNotice: Bool = true // 本来false
    @Published var navNotice: Bool = false
    @Published var navGroupDetail: Bool = false
    
    @Published var createGroup: Bool = false
    
    
    @MainActor
    func loadData() async {
        propertiesInitialize()
        asyncOperation({
            if self.apiHandler.isRunFetch(userDefaultKey: User.modelName) || self.reload {
                let userPredicate = User.keys.userID.eq(self.userID)
                let userInfo = try await self.apiHandler.list(User.self, where: userPredicate, keyName: "User")
                guard !userInfo.isEmpty else {
                    throw APIError.notFound
                }
                self.userInfo = userInfo[0]
            } else {
                let userList = try self.apiHandler.decodeUserDefault(modelType: [User].self, key: "User")
                if let list = userList, !list.isEmpty {
                    self.userInfo = list[0]
                } else {
                    // エラー
                }
            }
            
            if !self.asHost, self.userInfo?.accountType == .host {
                self.asHost = true
                UserDefaults.standard.set(self.asHost, forKey: "asHost")
            }
            if self.asHost {
                if self.apiHandler.isRunFetch(userDefaultKey: "hostGroups") || self.reload  {
                    if let hostGroupIDs = self.userInfo?.hostGroupIDs, !hostGroupIDs.isEmpty {
                        let hostGroupPredicate = self.apiService.orPredicateGroupByID(ids: hostGroupIDs, model: Group.keys.id)
                        let hostGroups = try await self.apiHandler.list(Group.self, where: hostGroupPredicate, keyName: "hostGroups")
                        self.hostGroups = hostGroups.sorted(by: {$0.createdAt! > $1.createdAt!})
                        
                    }
                } else {
                    self.hostGroups = try self.apiHandler.decodeUserDefault(modelType: [Group].self, key: "hostGroups") ?? []
                }
            }
            if self.apiHandler.isRunFetch(userDefaultKey: "belongingGroups") || self.reload  {
                if let belongingGroupIDs = self.userInfo?.belongingGroupIDs, !belongingGroupIDs.isEmpty {
                    let belongingGroupPredicate = self.apiService.orPredicateGroupByID(ids: belongingGroupIDs, model: Group.keys.id)
                    let belongingGroups = try await self.apiHandler.list(Group.self, where: belongingGroupPredicate, keyName: "belongingGroups")
                    self.belongingGroups = belongingGroups
                }
            } else {
                self.belongingGroups = try self.apiHandler.decodeUserDefault(modelType: [Group].self, key: "belongingGroups") ?? []
            }
        })
    }
    
    func propertiesInitialize() {
        userInfo = nil
        hostGroups = nil
        belongingGroups = nil
    }
}
