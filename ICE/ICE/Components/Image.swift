//
//  Image.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/29.
//

import SwiftUI

struct DefaultUserThumbnail: View {
    let color: Color
    var body: some View {
        Image(systemName: "person.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .foregroundStyle(Color(.indigo))
            .padding(.top, 5)
            .padding(.horizontal, 5)
            .background()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.indigo), lineWidth: 1))
    }
}

struct DefaultGroupThumbnail: View {
    let color: Color
    var body: some View {
        Image(systemName: "figure.2")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .foregroundStyle(Color(.indigo))
            .padding()
            .background()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.indigo), lineWidth: 2))
    }
}

struct Thumbnail: View {
    let type: ThumbnailType
    let thumbnail: UIImage
    var defaultColor: Color = Color(.indigo)
    var body: some View {
        if thumbnail.size == CGSize.zero {
            switch type {
            case .user:
                DefaultUserThumbnail(color: defaultColor)
            case .group:
                DefaultGroupThumbnail(color: defaultColor)
//            case .task:
//            case .reward:
            }
        } else {
            Image(uiImage: thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .background()
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.indigo), lineWidth: 2))
            
        }
    }
}

struct SettingIcon: View {
    var body: some View {
        Image(systemName: "gearshape")
            .resizable()
    }
}

struct AddSquareIcon: View {
    var body: some View {
        Image(systemName: "plus.square")
            .resizable()
    }
}
