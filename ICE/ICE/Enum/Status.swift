//
//  Status.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/18.
//

import Foundation
import SwiftUI

enum BelongingTaskStatus: String, Hashable {
    case accept
    case receiving = "挑戦中"
    case rejected = "再提出"
    case completed = "完了"
}

extension BelongingTaskStatus {
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
