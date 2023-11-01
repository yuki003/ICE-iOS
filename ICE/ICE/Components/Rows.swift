//
//  Rows.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/31.
//

import SwiftUI

struct ActiveTaskRow: View {
    let taskName: String
    var body: some View {
        Button(action: {
            print("Push Active Task Row")
        })
        {
            HStack(alignment: .center, spacing: 5) {
                Rectangle()
                    .frame(width: 5, height: 30)
                    .foregroundStyle(Color(.indigo))
                Text(taskName)
                    .font(.footnote.bold())
                    .foregroundStyle(Color.black)
            }
            .frame(width: 300, height: 30, alignment: .leading)
            .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
        }
    }
}

struct PendingRewardRow: View {
    let rewardName: String
    var status: String
    var body: some View {
        Button(action: {
            print("Push Pending Reward Row")
        })
        {
            HStack(alignment: .center, spacing: 5) {
                Rectangle()
                    .frame(width: 5, height: 30)
                    .foregroundStyle(Color(.jade))
                Text(rewardName)
                    .font(.footnote.bold())
                    .foregroundStyle(Color.black)
                Spacer()
                
                Text(status)
                    .font(.caption.bold())
                    .foregroundStyle(Color(.indigo))
                    .padding(.vertical, 3)
                    .padding(.horizontal, 8)
                    .overlay(RoundedRectangle(cornerRadius: 20.0).stroke(Color(.indigo), lineWidth: 2))
                    .padding(.trailing, 5)
                
                
            }
            .frame(width: 300, height: 30, alignment: .leading)
            .overlay(Rectangle().stroke(Color.gray, lineWidth: 1))
        }
    }
}
