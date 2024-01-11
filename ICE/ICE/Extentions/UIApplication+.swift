//
//  UIApplication+.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/04.
//

import Foundation
import SwiftUI

extension UIApplication {
    func closeKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
