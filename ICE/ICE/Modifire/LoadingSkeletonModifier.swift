//
//  LoadingSkeletonModifier.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/07/29.
//

import SwiftUI

struct LoadingSkeletonModifier<T>: ViewModifier {
    var object: T?
    var showSkeleton: Bool {
        object == nil
    }
    
    func body(content: Content) -> some View {
        content.redacted(reason: showSkeleton ? .placeholder: [])
            .allowsHitTesting(!showSkeleton)
    }
}
