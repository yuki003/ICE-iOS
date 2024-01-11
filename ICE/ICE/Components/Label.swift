//
//  Label.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/09.
//

import SwiftUI

struct SectionLabel: View {
    var text: String
    let font: Font
    let color: Color
    let width: CGFloat
    var placeHolder: String = ""
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Rectangle()
                .frame(width: width, height: width * 5)
                .foregroundStyle(color)
            Text(text.isEmpty ? placeHolder : text)
                .font(font)
                .foregroundStyle(text.isEmpty ? Color.gray : color)
                .lineLimit(2)
            Spacer()
        }
    }
}
struct SectionLabelWithAdd: View {
    var text: String
    let font: Font
    let color: Color
    let width: CGFloat
    let action: ()  -> Void
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Rectangle()
                .frame(width: width, height: width * 5)
                .foregroundStyle(color)
            Text(text)
                .font(font)
                .lineLimit(2)
            AddButton(action: action)
                .frame(width: 18, height: 18)
            Spacer()
        }
        .foregroundStyle(color)
    }
}

struct SectionLabelWithContent<Content: View>: View {
    var text: String
    let font: Font
    let color: Color
    let width: CGFloat
    let content: Content
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Rectangle()
                .frame(width: width, height: width * 5)
                .foregroundStyle(color)
            Text(text)
                .font(font)
                .lineLimit(2)
            content
            Spacer()
        }
        .foregroundStyle(color)
    }
}
