//
//  LoadingState.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/18.
//

import Foundation

enum LoadingState {
    case idle
    case loading
    case failed(Error)
    case loaded
}
