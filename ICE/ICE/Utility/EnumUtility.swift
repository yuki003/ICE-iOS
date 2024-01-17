//
//  EnumUtility.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/27.
//

import Foundation

class EnumUtility: ObservableObject {
    static let shared = EnumUtility()
    func translateFrequencyType(frequency: FrequencyType) -> String {
        switch frequency {
        case .onlyOnce:
            return "一度きり"
        case .everyDay:
            return "毎日"
        case .weekDay:
            return "平日"
        case .holiday:
            return "休日"
        case .oncePerWeek:
            return "週に一回"
        case .oncePerMonth:
            return "月に一回"
        case .oncePerYear:
            return "年に一回"
        }
    }
    func translateWhoGetsPaid(who: WhoGetsPaid) -> String {
        switch who {
        case .onlyOne:
            return "グループで1人だけ"
        case .everybody:
            return "グループ全員"
        case .limited:
            return "限定"
        }
    }
}
