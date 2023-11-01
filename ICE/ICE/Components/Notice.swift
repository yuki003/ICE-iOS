//
//  Notice.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/28.
//

import SwiftUI

struct CurrentActivityNotice: View {
    let message: String
    @Binding var isShowNotice: Bool
    @Binding var nav: Bool
    var body: some View {
        if isShowNotice {
            HStack(spacing: 5) {
                Text(message)
                    .lineLimit(1)
                    .font(.footnote.bold())
                    .foregroundStyle(Color(.indigo))
                    .onTapGesture {
                        withAnimation(.linear) {
                            isShowNotice = false
                            nav = true
                        }
                    }
                Spacer()
                XMarkButton(flag: $isShowNotice, width: 10, height: 10, color: Color(.indigo))
            }
            .padding(10)
            .frame(width: screenWidth())
            .foregroundStyle(Color(.indigo))
            .background()
            .roundedSection(color: Color(.indigo))
        }
    }
}

