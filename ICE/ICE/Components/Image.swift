//
//  Image.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/29.
//

import SwiftUI

struct DefaultUserThumbnail: View {
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
    var image: UIImage
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .background()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.indigo), lineWidth: 2))
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
