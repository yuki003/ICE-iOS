//
//  SectionModifier.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/28.
//

import SwiftUI

struct RoundedBorderModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
//            .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.indigo), lineWidth: 2))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(color, lineWidth: 2))
    }
}
