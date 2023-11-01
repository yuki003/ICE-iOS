//
//  SectionModifier.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/28.
//

import SwiftUI

struct RoundedSectionModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(color, lineWidth: 2))
    }
}
