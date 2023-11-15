//
//  GroupComponent.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/13.
//

import SwiftUI

struct CreateGroupCard: View {
    var groupName: String
    var image: UIImage
    var description: String
    var placeHolder: String = "グループ名を入力"
    var color: Color
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            NameLabel(text: groupName , font: .footnote.bold(), color: color, placeHolder: placeHolder)
                .frame(maxWidth: textFieldWidth(), alignment: .leading)
            
                if image.size == CGSize.zero {
                    DefaultGroupThumbnail()
                        .frame(width: 70, height: 70)
                } else {
                    Thumbnail(image: image)
                        .frame(width: 70, height: 70)
                }
            
            Text(description)
                .font(.footnote)
                .frame(maxWidth: textFieldWidth(), minHeight: 30, maxHeight: 300, alignment: .topLeading)
            
        }
        .padding(.vertical)
        .padding(.horizontal, 15)
        .frame(minWidth: cardWidth(), maxWidth: cardWidth(), minHeight: 250, maxHeight: .infinity, alignment: .leading)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.jade), lineWidth: 2))

    }
}

struct HomeGroupCard: View {
    let group: Group
    let image: UIImage
    var color: Color
    var member: Int {
        group.belongingUserIDs?.count ?? 0
    }
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            NameLabel(text: group.groupName , font: .footnote.bold(), color: color)
                .frame(maxWidth: textFieldWidth(), alignment: .leading)
            
                if image.size == CGSize.zero {
                    DefaultGroupThumbnail()
                        .frame(width: 70, height: 70)
                } else {
                    Thumbnail(image: image)
                        .frame(width: 70, height: 70)
                }
            if let description = group.description {
                Text(description)
                    .font(.footnote)
                    .frame(maxWidth: textFieldWidth(), minHeight: 30, maxHeight: 300, alignment: .topLeading)
            }
            Button(action:{
                print("Push member link")
            }){
                Text(member > 0 ? "メンバー：\(member)人" : "まだメンバーがいません")
                    .font(.caption.bold())
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 15)
        .frame(minWidth: cardWidth(), maxWidth: cardWidth(), minHeight: 250, maxHeight: .infinity, alignment: .leading)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.jade), lineWidth: 2))

    }
}
