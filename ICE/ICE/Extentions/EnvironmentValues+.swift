//
//  EnvironmentValues.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/30.
//

import SwiftUI

extension EnvironmentValues {
    var asGuestKey: Bool {
        get {
            return self[AsGuestKey.self]
        }
        set {
            self[AsGuestKey.self] = newValue
        }
    }
}
