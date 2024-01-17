//
//  Rows.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/31.
//

import SwiftUI

struct ActiveTaskRow: View {
    let task: Tasks
    @State var isOpen: Bool = false
    let action: () async throws -> Void
    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.3)){
                isOpen.toggle()
            }
        })
        {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    TaskIcon(thumbnail: TaskType(rawValue: task.iconName)!.icon, aspect: 30, selected: true)
                    Text(task.taskName)
                        .font(.callout.bold())
                        .foregroundStyle(Color.black)
                    Spacer()
                    Text("\(task.point.comma())pt")
                        .font(.callout.bold())
                        .foregroundStyle(Color(.indigo))
                        .padding(.trailing)
                }
                if isOpen {
                    if let description = task.description {
                        Text(description)
                            .font(.footnote.bold())
                            .foregroundStyle(Color.black)
                    }
                    Divider()
                    if let conditions = task.condition, !conditions.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            SectionLabel(text: "達成条件", font: .footnote.bold(), color: Color(.jade), width: 3)
                            ForEach(conditions.indices, id: \.self){ index in
                                if let condition = conditions[0], !condition.isEmpty {
                                    ItemizedRow(name: condition, font: .footnote.bold())
                                        .foregroundStyle(Color.black)
                                }
                            }
                        }
                    }
                    if task.startDate != nil || task.frequencyType != .onlyOnce {
                        VStack(alignment: .leading, spacing: 5) {
                            SectionLabel(text: "情報", font: .footnote.bold(), color: Color(.jade), width: 3)
                            if let end = task.endDate {
                                Text("\(task.startDate!.foundationDate.toFormat("yyyy/MM/dd"))から\(end.foundationDate.toFormat("yyyy/MM/dd"))まで")
                                    .font(.footnote.bold())
                                    .foregroundStyle(Color.black)
                            }
                            if task.frequencyType != .onlyOnce {
                                Text("\(EnumUtility().translateFrequencyType(frequency: task.frequencyType))チャレンジできます")
                                    .font(.footnote.bold())
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                    
                    ActionFillButton(label: "チャレンジする", action: action, color: Color(.indigo))
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.jade), lineWidth: 2))
        .frame(maxWidth: screenWidth(), maxHeight: 1000)
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

struct ItemizedRow: View {
    let name: String
    let font: Font
    var onUnderLine: Bool = false
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: "circle.fill")
                    .resizable()
                    .frame(width: 5, height: 5)
                Text(name)
                    .font(font)
                    .keyboardType(.emailAddress)
                Spacer()
                
            }
            .padding(8)
            if onUnderLine {
                Rectangle()
                    .frame(width: textFieldWidth(), height: 2)
                    .foregroundStyle(Color.gray)
            }
        }
        .frame(width: textFieldWidth())

    }
}
