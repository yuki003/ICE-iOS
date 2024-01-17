//
//  NavigationPath.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/12/11.
//

import Foundation
import SwiftUI

enum NavigationPathType: Hashable {
    case home
    case groupDetail(group: Group)
    case createTask(groupID: String)
    case createGroup
    case createReward(groupID: String)
    case taskDetail(task: Tasks)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine(0)
        case .groupDetail(let group):
            hasher.combine(1)
            hasher.combine(group.id) // 例えば、IDを使ってハッシュ値を生成
        case .createTask:
            hasher.combine(2)
        case .createGroup:
            hasher.combine(3)
        case .createReward:
            hasher.combine(4)
        case .taskDetail(let task):
            hasher.combine(5)
            hasher.combine(task.id)
        }
    }

    static func == (lhs: NavigationPathType, rhs: NavigationPathType) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home), (.createTask, .createTask), (.createGroup, .createGroup), (.createReward, .createReward):
            return true
        case (.groupDetail(let group1), .groupDetail(let group2)):
            return group1.id == group2.id // 例えば、IDを使って等価性を比較
        case (.taskDetail(let task1), .taskDetail(let task2)):
            return task1.id == task2.id
        default:
            return false
        }
    }
}
