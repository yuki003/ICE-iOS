//
//  Date+.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/16.
//

import SwiftUI

import Foundation
import SwiftUI

extension Date {
    func initFormatter(_ formatter: DateFormatter) {
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
    }
    func toFormat(_ style: String) -> String {
        let formatter = DateFormatter()
        initFormatter(formatter)
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = style
        return formatter.string(from: self)
    }
}
