//
//  Validation.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/21.
//

import Foundation

enum Validation: Equatable {
    case success
    case failed(message: String? = nil)
    
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}
