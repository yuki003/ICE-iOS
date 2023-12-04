//
//  Int+.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/08.
//

import Foundation
import SwiftUI

extension Int {
    func comma() -> String  {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        let num = "\(formatter.string(from: NSNumber(value: self)) ?? "")"
        
        return num
    }
}
