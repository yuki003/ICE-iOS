//
//  Type.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/18.
//

import Foundation
import SwiftUI

enum ThumbnailType: Hashable {
    case user
    case group
    case tasks
//    case rewards
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
}

extension TaskType {
    var icon: UIImage {
        return UIImage(named: self.rawValue) ?? UIImage()
    }
}
