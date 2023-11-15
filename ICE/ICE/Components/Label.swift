//
//  Label.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/09.
//

import SwiftUI

struct NameLabel: View {
    var text: String
    let font: Font
    let color: Color
    var placeHolder: String = ""
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Rectangle()
                .frame(width: 3, height: 15)
                .foregroundStyle(color)
            Text(text.isEmpty ? placeHolder : text)
                .font(font)
                .foregroundStyle(text.isEmpty ? Color.gray : color)
                .lineLimit(2)
        }
    }
}
