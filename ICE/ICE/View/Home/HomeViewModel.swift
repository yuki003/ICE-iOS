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
    @Published var hostGroups: [Group] = []
    @Published var belongingGroups: [Group] = []
    @Published var selectedGroup: Group?
    
    @Published var isShowNotice: Bool = true // 本来false
    @Published var navNotice: Bool = false
    @Published var navGroupDetail: Bool = false
    
    @Published var createGroup: Bool = false
    @Published var belongGroup: Bool = false
    
    
    @MainActor
    func loadData() async throws {
        asyncOperation({
            // 検証中のAPIアクセスを節約するためにコメントアウト＆スタブを導入
            
//            #if DEBUG
//                            self.hostGroups.append(Group(id: "3AF1D34C-7A50-497F-84E6-7344B6BD2345", groupName: "Jadigo Family", description: "Jadigo dev", thumbnailKey: "7adf414e-d90b-47db-bd1b-b2b9155aafbe3AF1D34C-7A50-497F-84E6-7344B6BD2345", hostUserIDs: ["7adf414e-d90b-47db-bd1b-b2b9155aafbe"]))
//            
//            #else
//                            hostGroups.append(Group(id: "7D343F68-7C4D-4D8C-B147-D93A8A6853A4", groupName: "Jadigo", description: "Jadigo", thumbnailKey: "2e695dab-390c-4fa5-8ac2-84d154b655d27D343F68-7C4D-4D8C-B147-D93A8A6853A4", hostUserIDs: ["2e695dab-390c-4fa5-8ac2-84d154b655d2"]))
//            #endif
            
            if self.apiHandler.isRunFetch(userDefaultKey: User.modelName) || self.reload {
                let userPredicate = User.keys.userID.eq(self.userID)
                async let userInfo = self.apiHandler.list(User.self, where: userPredicate)
                (self.userInfo) = try await (userInfo[0])
            } else {
                self.userInfo = try self.apiHandler.decodeUserDefault(modelType: User.self, key: User.modelName)
            }
            
            
            if self.apiHandler.isRunFetch(userDefaultKey: "hostGroups") || self.reload  {
                if let hostGroupIDs = self.userInfo?.hostGroupIDs, !hostGroupIDs.isEmpty {
                    let hostGroupPredicate = self.apiService.orPredicateGroupByID(ids: hostGroupIDs, model: Group.keys.id)
                    let hostGroups = try await self.apiHandler.list(Group.self, where: hostGroupPredicate, keyName: "hostGroups")
                    self.hostGroups = hostGroups.sorted(by: {$0.createdAt! > $1.createdAt!})
                    
                }
            } else {
                self.hostGroups = try self.apiHandler.decodeUserDefault(modelType: [Group].self, key: "hostGroups") ?? []
            }

//            if self.apiHandler.isRunFetch(userDefaultKey: "belongingGroups") || self.reload  {
//                if let belongingGroupIDs = self.userInfo?.belongingGroupIDs, !belongingGroupIDs.isEmpty {
//                    let belongingGroupPredicate = self.apiService.orPredicateGroupByID(ids: belongingGroupIDs, model: Group.keys.id)
//                    let belongingGroups = try await self.apiHandler.list(Group.self, where: belongingGroupPredicate, keyName: "belongingGroups")
//                    self.belongingGroups = belongingGroups
//                }
//            } else {
//                self.belongingGroups = try self.apiHandler.decodeUserDefault(modelType: [Group].self, key: "belongingGroups") ?? []
//            }
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
}
