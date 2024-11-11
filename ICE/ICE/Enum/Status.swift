//
//  Status.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/18.
//

import Foundation
import SwiftUI

enum TaskStatus: String, Hashable {
    case accept
    case receiving = "挑戦中"
    case rejected = "再提出"
    case completed = "完了"
    
    init(_ task: Tasks) {
        let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
        let asHost = UserDefaults.standard.bool(forKey: "asHost")
        if let receivingUserIDs = task.receivingUserIDs, (receivingUserIDs.contains(where: { $0 == userID}) || asHost) {
            self = .receiving
        } else if let rejectedUserIDs = task.rejectedUserIDs, rejectedUserIDs.contains(where: { $0 == userID}) {
            self = .rejected
        } else if let completedUserIDs = task.completedUserIDs, completedUserIDs.contains(where: { $0 == userID}) {
            self = .completed
        } else {
            self = .accept
        }
    }
}

extension TaskStatus {
    var color: Color {
        switch self {
        case .accept:
            return Color(.jade)
        case .receiving:
            return Color(.jade)
        case .rejected:
            return Color(.indigo)
        case .completed:
            return Color.gray
        }
    }
}

enum RewardStatus: String, Hashable {
    case none
    case earned = "獲得済み"
    case applied = "申請中"
    case rejected = "却下"
    
    init(_ reward: Rewards) {
        let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
        let asHost = UserDefaults.standard.bool(forKey: "asHost")
        if let getUserIDs = reward.getUserID, getUserIDs.contains(where: { $0 == userID}) {
            self = .earned
        } else if let rejectedUserIDs = reward.rejectedUserIDs, rejectedUserIDs.contains(where: { $0 == userID}) {
            self = .rejected
        } else if let appliedUserIDs = reward.appliedUserIDs, !appliedUserIDs.isEmpty, (appliedUserIDs.contains(where: { $0 == userID}) || asHost) {
            self = .applied
        } else {
            self = .none
        }
    }
}

extension RewardStatus {
    var color: Color {
        switch self {
        case .applied:
            return Color(.jade)
        case .earned:
            return Color(.jade)
        case .rejected:
            return Color(.indigo)
        case .none:
            return Color(.indigo)
        }
    }
}
