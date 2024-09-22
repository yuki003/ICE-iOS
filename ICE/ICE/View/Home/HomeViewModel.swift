//
//  HomeViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/23.
//

import SwiftUI
import Amplify
import AWSPluginsCore

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
        asyncOperation({ [self] in
            if !asHost, userInfo?.accountType == .host {
                asHost = true
                UserDefaults.standard.set(asHost, forKey: "asHost")
            }
            if apiHandler.isRunFetch(userDefaultKey: User.modelName) || reload {
                let userPredicate = User.keys.userID.eq(userID)
                let userInfo = try await apiHandler.list(User.self, where: userPredicate, keyName: "User")
                guard !userInfo.isEmpty else {
                    throw APIError.notFound
                }
                self.userInfo = userInfo[0]
            } else {
                let userList = try apiHandler.decodeUserDefault(modelType: [User].self, key: "User")
                if let list = userList, !list.isEmpty {
                    userInfo = list[0]
                }
            }
            
            if asHost {
                if apiHandler.isRunFetch(userDefaultKey: "hostGroups") || reload  {
                    if let hostGroupIDs = userInfo?.hostGroupIDs, !hostGroupIDs.isEmpty {
                        let hostGroupPredicate = apiService.orPredicateGroupByID(ids: hostGroupIDs, model: Group.keys.id)
                        let hostGroups = try await apiHandler.list(Group.self, where: hostGroupPredicate, keyName: "hostGroups")
                        self.hostGroups = hostGroups.sorted(by: {$0.createdAt! > $1.createdAt!})
                    } else {
                        hostGroups = []
                    }
                } else {
                    hostGroups = try apiHandler.decodeUserDefault(modelType: [Group].self, key: "hostGroups") ?? []
                }
            }
            if apiHandler.isRunFetch(userDefaultKey: "belongingGroups") || reload  {
                if let belongingGroupIDs = userInfo?.belongingGroupIDs, !belongingGroupIDs.isEmpty {
                    let belongingGroupPredicate = apiService.orPredicateGroupByID(ids: belongingGroupIDs, model: Group.keys.id)
                    let belongingGroups = try await apiHandler.list(Group.self, where: belongingGroupPredicate, keyName: "belongingGroups")
                    self.belongingGroups = belongingGroups
                } else {
                    belongingGroups = []
                }
            } else {
                belongingGroups = try apiHandler.decodeUserDefault(modelType: [Group].self, key: "belongingGroups") ?? []
            }
        })
    }
    
    func propertiesInitialize() {
        userInfo = nil
        hostGroups = nil
        belongingGroups = nil
    }
    
//    func confirmSession() async throws {
//        let session = try await Amplify.Auth.fetchAuthSession()
//        if session.isSignedIn {
//            print("セッションは有効です")
//        } else {
//            print("セッションが無効です")
//        }
//    }
//    
//    func reConnectSession() async throws {
//        let options = AuthFetchSessionRequest.Options(forceRefresh: true)
//        let session = try await Amplify.Auth.fetchAuthSession(options: options)
//        guard let awsCredentialsProvider = session as? AuthAWSCredentialsProvider else {
//            print("Failed to retrieve AWS credentials.")
//            return
//        }
//        
//        let credentials = try awsCredentialsProvider.getAWSCredentials().get()
//        print("AWS Credentials: \(credentials)")
//    }
}
