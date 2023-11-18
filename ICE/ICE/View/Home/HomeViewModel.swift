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
    @Published var hostGroupThumbnails: [UIImage] = []
    @Published var belongingGroups: [Group] = []
    @Published var belongingGroupThumbnails: [UIImage] = []
    
    @Published var isShowNotice: Bool = true // 本来false
    @Published var navNotice: Bool = false
    
    @Published var createGroup: Bool = false
    @Published var belongGroup: Bool = false
    
    
    @MainActor
    func loadData() async throws {
        asyncOperation({
            // 検証中のAPIアクセスを節約するためにコメントアウト＆スタブを導入
            
//            let userPredicate = User.keys.userID.eq(self.userID)
//            async let userInfo = self.apiHandler.list(User.self, where: userPredicate)
//            (self.userInfo) = try await (userInfo[0])
//            
//            var hostGroupPredicate: QueryPredicateGroup = .init(type: .or)
//            if let hostGroupIDs = self.userInfo?.hostGroupIDs, !hostGroupIDs.isEmpty {
//                for id in hostGroupIDs {
//                    hostGroupPredicate = hostGroupPredicate.or(Group.keys.id.eq(id))
//                }
//                var hostGroups = try await self.apiHandler.list(Group.self, where: hostGroupPredicate)
//                self.hostGroups = hostGroups
                
#if DEBUG
                self.hostGroups.append(Group(id: "5470851A-A7A7-4564-B8FB-4DD6DB4637BB", groupName: "Jadigo Family", description: "Jadigo First Group!!", thumbnailKey: "7adf414e-d90b-47db-bd1b-b2b9155aafbe5470851A-A7A7-4564-B8FB-4DD6DB4637BB", hostUserIDs: ["7adf414e-d90b-47db-bd1b-b2b9155aafbe"]))
                
#else
                hostGroups.append(Group(id: "7D343F68-7C4D-4D8C-B147-D93A8A6853A4", groupName: "Jadigo", description: "Jadigo", thumbnailKey: "2e695dab-390c-4fa5-8ac2-84d154b655d27D343F68-7C4D-4D8C-B147-D93A8A6853A4", hostUserIDs: ["2e695dab-390c-4fa5-8ac2-84d154b655d2"]))
#endif
                
                if !self.hostGroups.isEmpty {
                    for hostGroup in self.hostGroups {
                        let thumbnail = try await self.storage.downloadImage(key: hostGroup.thumbnailKey)
                        self.hostGroupThumbnails.append(thumbnail)
                    }
                }
//            }
            
            var belongingGroupPredicate: QueryPredicateGroup = .init()
            if let belongingGroupIDs = self.userInfo?.belongingGroupIDs, !belongingGroupIDs.isEmpty {
                for id in belongingGroupIDs {
                    belongingGroupPredicate = belongingGroupPredicate.or(Group.keys.id.eq(id))
                }
                let belongingGroups = try await self.apiHandler.list(Group.self, where: belongingGroupPredicate)
                self.belongingGroups = belongingGroups
            }
            
            withAnimation(.linear) {
                self.state = .loaded
            }
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
}
