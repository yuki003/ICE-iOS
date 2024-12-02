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
    var space: Bool = true
    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Rectangle()
                .frame(width: width, height: width * 5)
                .foregroundStyle(color)
            Text(text.isEmpty ? placeHolder : text)
                .font(font)
                .foregroundStyle(text.isEmpty ? Color.gray : color)
                .lineLimit(2)
            if space {
                Spacer()
            }
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

struct StatusLabel: View {
    let label: String
    let color: Color
    let font: Font
    var body: some View {
        Text(label)
            .padding(.vertical, 3)
            .padding(.horizontal, 10)
            .font(font)
            .foregroundStyle(color)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(color, lineWidth: 2))
    }
}
