//
//  Image+.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/27.
//

import Foundation
import SwiftUI

extension UIImage {
    func isEmpty() -> Bool {
        self.size == CGSize.zero
    }
}
