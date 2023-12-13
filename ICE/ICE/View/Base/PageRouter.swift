//
//  PageRouter.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/12/11.
//

import Foundation
import SwiftUI

final class PageRouter: ObservableObject {
    @Published var path = NavigationPath()
    // ... 省略
}
