//
//  String+.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/21.
//

import Foundation
import SwiftUI
import CryptoKit

extension String {
    mutating func initialize() {
        self = ""
    }
    
    func containsEmoji() -> Bool {
        contains { $0.isEmoji }
    }
    
    func isMatch(pattern: Regex) -> Bool {
        let pattern = pattern.rawValue
                let regex = try! NSRegularExpression(pattern:pattern)
                return regex.firstMatch(in:self, range:NSRange(self.startIndex..., in:self)) != nil
    }
    
    
    func hashed() -> String {
        // SHA256 などのハッシュ関数を使用して文字列をハッシュ化
        guard let data = self.data(using: .utf8) else { return "" }
        let hashedData = SHA256.hash(data: data)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    var isNotEmpty: Bool {
        !self.isEmpty
    }
}
