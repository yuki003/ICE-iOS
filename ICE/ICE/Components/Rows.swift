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
    @Binding var selected: Tasks?
    @State var isOpen: Bool = false
    @Binding var navTo: Bool
    @Binding var reload: Bool
    let action: () async throws -> Void
    let asHost: Bool = UserDefaults.standard.bool(forKey: "asHost")
    var userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    var status: TaskStatus
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
                                ActionFillButton(label: "レポート確認", action: {
                                    isOpen = false
                                    router.path.append(NavigationPathType.taskApproval(task: task))}, color: Color(.indigo))
                                    .frame(width: (screenWidth() - 84) / 2)
                            } else if status == .accept {
                                ActionFillButton(label: "編集する", action:{
                                    isOpen = false
                                    rowNavigation() }, color: Color(.indigo))
                                    .frame(width: (screenWidth() - 84) / 2)
                            }
                            ActionFillButton(label: "インサイト", action:{
                                isOpen = false
                                // TODO: インサイト画面
                            }, color: Color(.jade))
                                .frame(width: (screenWidth() - 84) / 2)
                        }
                        .frame(width: (screenWidth() - 84))
                    } else {
                        switch status {
                        case .accept:
                            ActionFillButton(label: "挑戦する", action: action, color: Color(.indigo))
                        case .receiving:
                            ActionFillButton(label: "報告する", action: { rowNavigation() }, color: Color(.jade))
                        case .rejected:
                            ActionFillButton(label: "コメントを見る", action: { rowNavigation() }, color: Color(.jade))
                        case .completed:
                            ActionFillButton(label: "記録を見る", action: { rowNavigation() }, color: Color(.indigo))
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
    
    func rowNavigation() {
        isOpen = false
        selected = task
        navTo = true
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
    let reward: Rewards
    @Binding var selected: Rewards?
    @State var isOpen: Bool = false
    @Binding var navTo: Bool
    @Binding var reload: Bool
    let action: () async throws -> Void
    let asHost: Bool = UserDefaults.standard.bool(forKey: "asHost")
    let userID: String = UserDefaults.standard.string(forKey: "userID") ?? ""
    var status: RewardStatus
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
                    if let thumbnail = reward.thumbnailKey, thumbnail.isNotEmpty {
                        TaskIcon(thumbnail: UIImage(url: thumbnail), aspect: 30, selected: true)
                    } else {
                        Thumbnail(type: ThumbnailType.rewards, image: UIImage(), aspect: 30)
                    }
                    Text(reward.rewardName)
                        .font(.callout.bold())
                        .foregroundStyle(Color.black)
                    Spacer()
                    
                        if asHost, status == .applied {
                            StatusLabel(label: "申請あり", color: Color(.indigo), font: .callout.bold())
                        } else if !asHost, status != .none {
                            StatusLabel(label: status.rawValue, color: status.color, font: .callout.bold())
                        }
                    Text("\(reward.cost.comma())pt")
                        .font(.callout.bold())
                        .foregroundStyle(Color(.indigo))
                        .padding(.trailing, 10)
                }
                if isOpen {
                    if let description = reward.description {
                        HStack {
                            Text(description)
                                .font(.footnote.bold())
                                .foregroundStyle(Color.black)
                        Spacer()
                        }
                    }
                    Divider()
                    if reward.startDate != nil || reward.frequencyType != .onlyOnce {
                        VStack(alignment: .leading, spacing: 5) {
                            SectionLabel(text: "情報", font: .footnote.bold(), color: Color(.jade), width: 3)
                            if let end = reward.endDate {
                                Text("\(reward.startDate!.foundationDate.toFormat("yyyy/MM/dd"))から\(end.foundationDate.toFormat("yyyy/MM/dd"))まで")
                                    .font(.footnote.bold())
                                    .foregroundStyle(Color.black)
                            }
                            if reward.frequencyType != .onlyOnce {
                                Text("\(EnumUtility().translateFrequencyType(frequency: reward.frequencyType))ゲットできます")
                                    .font(.footnote.bold())
                                    .foregroundStyle(Color.black)
                            }
                        }
                    }
                    if asHost {
                        HStack(spacing: 20) {
                            if status == .applied {
                                ActionFillButton(label: "申請確認", action:{
                                    isOpen = false
                                    router.path.append(NavigationPathType.rewardApproval(reward: reward)) }, color: Color(.indigo))
                                    .frame(width: (screenWidth() - 84) / 2)
                            } else if status == .none {
                                ActionFillButton(label: "編集する", action:{
                                    isOpen = false
                                    rowNavigation()
                                }, color: Color(.indigo))
                                    .frame(width: (screenWidth() - 84) / 2)
                            }
                            ActionFillButton(label: "インサイト", action:{
                                isOpen = false
                                // TODO: インサイト画面
                            }, color: Color(.jade))
                                .frame(width: (screenWidth() - 84) / 2)
                        }
                        .frame(width: (screenWidth() - 84))
                    } else {
                        switch status {
                        case .none:
                            ActionFillButton(label: "申請する", action: action, color: Color(.indigo))
                        case .applied:
                            ActionFillButton(label: "申請取消し", action: action , color: Color.red)
                        case .rejected:
                            ActionFillButton(label: "再申請する", action: action, color: Color(.jade))
                        case .earned:
                            ActionFillButton(label: "記録を見る", action: { rowNavigation() }, color: Color(.indigo))
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
    
    func rowNavigation() {
        isOpen = false
        selected = reward
        navTo = true
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

struct UserRow: View {
    let user: User
    @Binding var selectedUserID: String
    @State var isOpen: Bool = false
    let forwardAction: () async throws -> Void
    let rejectAction: () async throws -> Void
    var body: some View {
        Button(action: {
            withAnimation(.easeOut(duration: 0.3)){
                isOpen.toggle()
                selectedUserID = user.userID
            }
        })
        {
            VStack(alignment: .center, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Thumbnail(type: ThumbnailType.user, aspect: 30)
                    Text(user.userName)
                        .font(.callout.bold())
                        .foregroundStyle(Color.black)
                    Spacer()
                }
                if isOpen {
                    HStack(spacing: 10) {
                        ActionFillButton(label: "却下",
                                         action: rejectAction,
                                         color: Color.red)
                        ActionFillButton(label: "承認", action: forwardAction, color: Color(.indigo))
                        
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.indigo), lineWidth: 2))
        .frame(maxWidth: screenWidth(), maxHeight: 1000)
    }
}
