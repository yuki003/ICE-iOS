//
//  LoadingModifier.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/25.
//

import SwiftUI

struct LoadingModifier: ViewModifier {
    @Binding var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
          content
            if isLoading {
                LoadingView()
            }
        }
        .animation(.linear, value: isLoading)
    }
}

