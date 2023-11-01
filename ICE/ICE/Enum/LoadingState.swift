//
//  LoadingState.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/18.
//

import Foundation

enum LoadingState: Equatable {
    static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
        switch (lhs, rhs) {
            
        case (.idle, .idle):
            return true
        case (.loading, .loading):
            return true
        case (.loaded, .loaded):
            return true
        default:
            return false
        }
    }
    
    case idle
    case loading
    case failed(Error)
    case loaded
}
