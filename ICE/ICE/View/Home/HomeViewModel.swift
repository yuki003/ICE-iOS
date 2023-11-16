//
//  HomeViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/23.
//

import SwiftUI
import Amplify

final class HomeViewModel: ObservableObject {
    @Published var state: LoadingState = .idle
    @ObservedObject var auth = AmplifyAuthService()
    @ObservedObject var storage = AmplifyStorageService()
    @ObservedObject var apiHandler = APIHandler()
    
    @Published var userInfo: User?
    @Published var hostGroups: [Group] = []
    @Published var hostGroupThumbnails: [UIImage] = []
    @Published var belongingGroups: [Group] = []
    @Published var belongingGroupThumbnails: [UIImage] = []
    
    @Published var isShowNotice: Bool = true // 本来false
    @Published var navNotice: Bool = false
    @Published var alert: Bool = false
    @Published var alertMessage: String?
    
    @Published var createGroup: Bool = false
    @Published var belongGroup: Bool = false
    
    @Published var userID: String? = UserDefaults.standard.string(forKey: "userID")
    
    @MainActor
    func loadData() async throws {
        do {
            // 検証中のAPIアクセスを節約するためにコメントアウト＆スタブを導入
            
            guard let id = userID else { throw APIError.userIdNotExists }
            let userPredicate = User.keys.userID.eq(id)
            async let userInfo = apiHandler.list(User.self, where: userPredicate)
            (self.userInfo) = try await (userInfo[0])
            
            var hostGroupPredicate: QueryPredicateGroup = .init(type: .or)
            if let hostGroupIDs = self.userInfo?.hostGroupIDs, !hostGroupIDs.isEmpty {
                for id in hostGroupIDs {
                    hostGroupPredicate = hostGroupPredicate.or(Group.keys.id.eq(id))
                }
                let hostGroups = try await apiHandler.list(Group.self, where: hostGroupPredicate)
               self.hostGroups = hostGroups
            
//            hostGroups.append(Group(id: "5470851A-A7A7-4564-B8FB-4DD6DB4637BB", groupName: "Jadigo Family", description: "Jadigo First Group!!", thumbnailKey: "7adf414e-d90b-47db-bd1b-b2b9155aafbe5470851A-A7A7-4564-B8FB-4DD6DB4637BB", hostUserIDs: ["7adf414e-d90b-47db-bd1b-b2b9155aafbe"]))
            
                if !hostGroups.isEmpty {
                    for hostGroup in hostGroups {
                        let thumbnail = try await storage.downloadImage(key: hostGroup.thumbnailKey)
                        hostGroupThumbnails.append(thumbnail)
                    }
                }
            }
            
            var belongingGroupPredicate: QueryPredicateGroup = .init()
            if let belongingGroupIDs = self.userInfo?.belongingGroupIDs, !belongingGroupIDs.isEmpty {
                for id in belongingGroupIDs {
                    belongingGroupPredicate = belongingGroupPredicate.or(Group.keys.id.eq(id))
                }
                let belongingGroups = try await apiHandler.list(Group.self, where: belongingGroupPredicate)
               self.belongingGroups = belongingGroups
            }
            
            withAnimation(.linear) {
                state = .loaded
            }
        } catch let error as APIError {
            alertMessage = error.localizedDescription
            alert = true
            withAnimation(.linear) {
                state = .failed(error)
            }
        } catch let error {
            alertMessage = error.localizedDescription
            alert = true
            withAnimation(.linear) {
                state = .failed(error)
            }
        }
    }
}
