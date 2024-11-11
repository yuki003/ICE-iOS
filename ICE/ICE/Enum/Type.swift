//
//  Type.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/18.
//

import Foundation
import SwiftUI
import Amplify

enum ThumbnailType: Hashable {
    case user
    case group
    case tasks
    case rewards
}

enum TaskType: String, CaseIterable {
    case document = "Document"
    case programing = "Programing"
    case work = "Work"
    case babyCare = "BabyCare"
    case childCare = "ChildCare"
    case cooking = "Cooking"
    case driving = "Driving"
    case laundry = "Laundry"
    case abstinenceAlcohol = "AbstinenceAlcohol"
    case fitness = "Fitness"
    case search = "Search"
    case selfWork = "SelfWork"
    case study = "Study"
    case workOut = "WorkOut"
    case defaultIcon = "logo"
    
    init(type: String) {
        switch type {
        case TaskType.document.rawValue:
            self = .document
        case TaskType.programing.rawValue:
            self = .programing
        case TaskType.work.rawValue:
            self = .work
        case TaskType.babyCare.rawValue:
            self = .babyCare
        case TaskType.childCare.rawValue:
            self = .childCare
        case TaskType.cooking.rawValue:
            self = .cooking
        case TaskType.driving.rawValue:
            self = .driving
        case TaskType.laundry.rawValue:
            self = .laundry
        case TaskType.abstinenceAlcohol.rawValue:
            self = .abstinenceAlcohol
        case TaskType.fitness.rawValue:
            self = .fitness
        case TaskType.search.rawValue:
            self = .search
        case TaskType.selfWork.rawValue:
            self = .selfWork
        case TaskType.study.rawValue:
            self = .study
        case TaskType.workOut.rawValue:
            self = .workOut
        default:
            self = .defaultIcon
        }
    }
}

extension TaskType {
    var icon: UIImage {
        return UIImage(named: self.rawValue) ?? UIImage()
    }
}

enum APIType: CaseIterable {
    case get
    case list
}


enum AppModelType: String, Equatable {
    case User = "User"
    case Group = "Group"
    case Tasks = "Tasks"
    case Rewards = "Rewards"
    case TaskReports = "TaskReports"
    case GroupPointsHistory = "GroupPointsHistory"
    
    init(type: String) {
        switch type {
        case AppModelType.User.rawValue:
            self = AppModelType.User
        case AppModelType.Group.rawValue:
            self = AppModelType.Group
        case AppModelType.Tasks.rawValue:
            self = AppModelType.Tasks
        case AppModelType.Rewards.rawValue:
            self = AppModelType.Rewards
        case AppModelType.TaskReports.rawValue:
            self = AppModelType.TaskReports
        case AppModelType.GroupPointsHistory.rawValue:
            self = AppModelType.GroupPointsHistory
        default:
            self = AppModelType.User
        }
    }
    
    func castModel(_ model: Model) -> Model {
        switch self {
        case .User:
            model as! User
        case .Group:
            model as! Group
        case .Tasks:
            model as! Tasks
        case .Rewards:
            model as! Rewards
        case .TaskReports:
            model as! TaskReports
        case .GroupPointsHistory:
            model as! GroupPointsHistory
        }
    }
    
    func findTargetIndex(_ models: [Model], _ target: Model) -> Int? {
        for model in models {
            switch self {
            case .User:
                let element = model as! User
                let target = target as! User
                let lists = models as! [User]
                if element.id == target.id {
                    return lists.firstIndex(where: {$0.id == target.id})
                }
            case .Group:
                let element = model as! Group
                let target = target as! Group
                let lists = models as! [Group]
                if element.id == target.id {
                    return lists.firstIndex(where: {$0.id == target.id})
                }
            case .Tasks:
                let element = model as! Tasks
                let target = target as! Tasks
                let lists = models as! [Tasks]
                if element.id == target.id {
                    return lists.firstIndex(where: {$0.id == target.id})
                }
            case .Rewards:
                let element = model as! Rewards
                let target = target as! Rewards
                let lists = models as! [Rewards]
                if element.id == target.id {
                    return lists.firstIndex(where: {$0.id == target.id})
                }
            case .TaskReports:
                let element = model as! TaskReports
                let target = target as! TaskReports
                let lists = models as! [TaskReports]
                if element.id == target.id {
                    return lists.firstIndex(where: {$0.id == target.id})
                }
            case .GroupPointsHistory:
                let element = model as! GroupPointsHistory
                let target = target as! GroupPointsHistory
                let lists = models as! [GroupPointsHistory]
                if element.id == target.id {
                    return lists.firstIndex(where: {$0.id == target.id})
                }
            }
        }
        return nil
    }
}
//enum HostTaskActionType: String, Hashable {
//    case edit
//    case insight
//}
//
//extension HostTaskActionType {
//    var color: Color {
//        switch self {
//        case .edit:
//            return Color(.indigo)
//        case .insight:
//            return Color(.jade)
//        }
//    }
//}
