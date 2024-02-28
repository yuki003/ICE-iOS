//
//  Rows.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/31.
//

import SwiftUI
import Kingfisher

struct TaskRow: View {
    let task: Tasks
    @State var isOpen: Bool = false
    let action: () async throws -> Void
    let asHost: Bool
    var userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    var status: BelongingTaskStatus
    @EnvironmentObject var router: PageRouter
    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.3)){
                isOpen.toggle()
            }
        })
        {
            VStack(alignment: .center, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    TaskIcon(thumbnail: TaskType(rawValue: task.iconName)!.icon, aspect: 30, selected: true)
                    Text(task.taskName)
                        .font(.callout.bold())
                        .foregroundStyle(Color.black)
                    Spacer()
                    if asHost {
                        if task.hasPendingReport {
                            StatusLabel(label: "レポートあり", color: Color(.indigo), font: .callout.bold())
                        }
                    } else {
                        if status != .accept {
                            StatusLabel(label: status.rawValue, color: status.color, font: .callout.bold())
                        }
                    }
                    Text("\(task.point.comma())pt")
                        .font(.callout.bold())
                        .foregroundStyle(Color(.indigo))
                        .padding(.trailing, 10)
                }
                if isOpen {
                    if let description = task.description {
                        HStack {
                            Text(description)
                                .font(.footnote.bold())
                                .foregroundStyle(Color.black)
                        Spacer()
                        }
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
                    if asHost {
                        HStack(spacing: 20) {
                            if task.hasPendingReport {
                                ActionFillButton(label: "レポート確認", action: {router.path.append(NavigationPathType.taskApproval(task: task))}, color: Color(.indigo))
                                    .frame(width: (screenWidth() - 84) / 2)
                            } else if status == .accept {
                                ActionFillButton(label: "編集する", action: {router.path.append(NavigationPathType.createGroup)}, color: Color(.indigo))
                                    .frame(width: (screenWidth() - 84) / 2)
                            }
                            ActionFillButton(label: "インサイト", action: {router.path.append(NavigationPathType.createGroup)}, color: Color(.jade))
                                .frame(width: (screenWidth() - 84) / 2)
                        }
                        .frame(width: (screenWidth() - 84))
                    } else {
                        switch status {
                        case .accept:
                            ActionFillButton(label: "挑戦する", action: action, color: Color(.indigo))
                        case .receiving:
                            ActionFillButton(label: "報告する", action: {router.path.append(NavigationPathType.taskReport(task: task))}, color: Color(.jade))
                        case .rejected:
                            ActionFillButton(label: "再報告する", action: {router.path.append(NavigationPathType.taskReport(task: task))}, color: Color(.jade))
                        case .completed:
                            ActionFillButton(label: "記録を見る", action: {router.path.append(NavigationPathType.taskReport(task: task))}, color: Color(.indigo))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(status.color, lineWidth: 2))
        .frame(maxWidth: screenWidth(), maxHeight: 1000)
    }
}

struct ApprovalReportRow: View {
    @FocusState private var focused: FormField?
    @State var isOpen: Bool = false
    @Binding var showImage: Bool
    @Binding var selectedImage: String
    var userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    @Binding var comment: String
    let task: Tasks
    let reportWithUser: ReportWithUserInfo
    let approvalAction: () async -> Void
    let rejectAction: () async -> Void
    var reportPics: [String?] {
        [reportWithUser.report.picture1,reportWithUser.report.picture2,reportWithUser.report.picture3]
    }
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Button(action: {
                isOpen.toggle()
            })
            {
                HStack(alignment: .center, spacing: 10) {
                    Thumbnail(type: ThumbnailType.user, aspect: 30)
                    Text(reportWithUser.user?.userName ?? "不明なユーザー")
                        .font(.callout.bold())
                        .foregroundStyle(Color.black)
                    Spacer()
                    ChevronIcon(direction: isOpen ? .down : .right)
                        .frame(width: isOpen ? 15 : 10, height: isOpen ? 10 : 15)
                        .font(.callout)
                        .foregroundStyle(Color(.indigo))
                }
            }
            if isOpen {
                if let description = task.description {
                    HStack {
                        Text(description)
                            .font(.footnote.bold())
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
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
                
                if let report = reportWithUser.report.reports?.last, let text = report {
                    VStack(alignment: .leading, spacing: 5) {
                        SectionLabel(text: "報告内容", font: .footnote.bold(), color: Color(.jade), width: 3)
                        Text(text)
                            .font(.footnote.bold())
                            .foregroundStyle(Color.black)
                    }
                }
                
                if !reportPics.isEmpty {
                    HStack(alignment: .center, spacing: 10) {
                        ForEach (reportPics.indices, id:\.self){ index in
                            if let pic = reportPics[index] {
                                Button(action: {
                                    selectedImage = pic
                                    showImage = true
                                })
                                {
                                    KFImage(URL(string: pic))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 60, height: 60)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                    }
                }
                DescriptionTextEditor(description: $comment, focused: _focused, placeholder: "コメントを書こう")
                HStack(spacing: 20) {
                    ActionFillButton(label: "却下する", action: { await rejectAction() }, color: Color(.indigo))
                        .frame(width: (screenWidth() - 84) / 2)
                    ActionFillButton(label: "承認する", action: {await approvalAction()}, color: Color(.jade))
                        .frame(width: (screenWidth() - 84) / 2)
                }
                .frame(width: (screenWidth() - 84))
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.indigo), lineWidth: 2))
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
