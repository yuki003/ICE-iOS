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
    @ObservedObject var apiHandler = APIHandler()
    
    @Published var userInfo: User?
    @Published var hostGroups: [Group] = []
    @Published var belongingGroups: [Group] = []
    
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
//            guard let id = userID else { throw APIError.userIdNotExists }
//            let userPredicate = User.keys.userID.eq(id)
//            async let userInfo = apiHandler.list(User.self, where: userPredicate)
//            (self.userInfo) = try await (userInfo[0])
            
            var hostGroupPredicate: QueryPredicateGroup = .init()
            if let hostGroupIDs = self.userInfo?.hostGroupIDs, !hostGroupIDs.isEmpty {
                for id in hostGroupIDs {
                    hostGroupPredicate = hostGroupPredicate.or(Group.keys.id.eq(id))
                }
                let hostGroups = try await apiHandler.list(Group.self, where: hostGroupPredicate)
               self.hostGroups = hostGroups
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
