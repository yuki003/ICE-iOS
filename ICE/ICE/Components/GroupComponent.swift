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
            SectionLabel(text: groupName , font: .footnote.bold(), color: color, width: 3.0, placeHolder: placeHolder)
                .frame(maxWidth: textFieldWidth(), alignment: .leading)
            
            Thumbnail(type:ThumbnailType.group, image: image, aspect: 70)
            Text(description)
                .font(.footnote)
                .foregroundStyle(Color.black)
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
    let url: String
    var color: Color
    var member: Int {
        group.belongingUserIDs?.count ?? 0
    }
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            SectionLabel(text: group.groupName , font: .footnote.bold(), color: color, width: 3.0)
                .frame(maxWidth: textFieldWidth(), alignment: .leading)
            
            Thumbnail(type:ThumbnailType.group, url: url, aspect: 70)
            
            GroupDescription(description: group.description)
            
            Button(action:{
                print("Push member link")
            }){
                Text(member > 0 ? "メンバー：\(member)人" : "まだメンバーがいません")
                    .font(.caption.bold())
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 15)
        .frame(minWidth: cardWidth(), maxWidth: cardWidth(), minHeight: 200, maxHeight: .infinity, alignment: .leading)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.jade), lineWidth: 2))

    }
}

struct GroupDescription: View {
    var description: String?
    var body: some View {
        if let description = description {
            Text(description)
                .font(.footnote)
                .foregroundStyle(Color.black)
                .frame(maxWidth: textFieldWidth(), minHeight: 30, maxHeight: 30, alignment: .topLeading)
        }
    }
}
