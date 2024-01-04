//
//  GroupDetailView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/18.
//

import SwiftUI
import Amplify
struct GroupDetailView: View {
    @StateObject var vm: GroupDetailViewModel
    @EnvironmentObject var router: PageRouter
    
    @State var inviteFlag: Bool = false
    var body: some View {
        DestinationHolderView(router: router) {
            VStack {
                switch vm.state {
                case .idle:
                    Color.clear.onAppear { vm.state = .loading }
                case .loading:
                    LoadingView().onAppear{
                        Task {
                            try await vm.loadData()
                        }
                    }
                case let .failed(error):
                    Text(error.localizedDescription)
                case .loaded:
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 20) {
                            VStack(alignment: .center, spacing: 15) {
                                Text(vm.groupInfo.groupName)
                                    .font(.headline.bold())
                                    .foregroundStyle(Color(.indigo))
                                
                                Thumbnail(type: ThumbnailType.group, url: vm.groupInfo.thumbnailKey ?? "", aspect: 70)
                                
                                GroupDescription(description: vm.groupInfo.description)
                                
                                Divider()
                            }
                            makeMemberList()
                            makeTaskList()
                            makeRewardList()
                        }
                        .padding()
                        .frame(width: deviceWidth())
                        .alert(isPresented: $vm.alert) {
                            Alert(
                                title: Text(
                                    "エラー"
                                ),
                                message: Text(
                                    vm.alertMessage ?? "操作をやり直してください。"
                                ),
                                dismissButton: .default(
                                    Text(
                                        "閉じる"
                                    )
                                )
                            )
                        }
                    }
                    .sheet(isPresented: $inviteFlag) {
                        ActivityViewController(activityItems: [vm.invitationBaseText], applicationActivities: nil)
                    }
                    .refreshable {
                        Task {
                            vm.reload = true
                            try await vm.loadData()
                        }
                    }
                }
            }
            .userToolbar(state: vm.state, userName: nil, dismissExists: true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                vm.state = .idle
            }
        }
    }
    
    @ViewBuilder
    func makeMemberList() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if vm.asHost {
                SectionLabelWithContent(text: "メンバー", font: .callout.bold(), color: Color(.indigo), width: 5.0, content: InviteMembersButton(flag: $inviteFlag))
            } else {
                SectionLabel(text: "メンバー", font: .callout.bold(), color: Color(.indigo), width: 5.0)
            }
            HStack(spacing: 10) {
                if vm.displayUser.count > 0 {
                    ForEach(vm.displayUser.indices, id: \.self) { index in
                        let user = vm.users[index]
                        Button(action: {
                            // ユーザー詳細に遷移、ポップアップで詳細表示でも可
                        }) {
                            Thumbnail(type: ThumbnailType.user, url: user.thumbnailKey ?? "", aspect: 30)
                        }
                        if vm.notDisplayUserCount > 0 {
                            Button(action: {
                                // ユーザー一覧に遷移、ポップアップで詳細表示でも可
                            }) {
                                Text("他\(vm.notDisplayUserCount)人のユーザー")
                            }
                        }
                    }
                } else {
                    Text("メンバーがいません")
                        .font(.callout.bold())
                        .foregroundStyle(Color.black.opacity(0.8))
                        .padding(5)
                }
            }
            .padding(.leading)
        }
    }
    @ViewBuilder
    func makeTaskList() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                if !vm.asHost {
                    SectionLabel(text: "タスク", font: .callout.bold(), color: Color(.indigo), width: 5.0)
                } else {
                    SectionLabelWithAdd(text: "タスク", font: .callout.bold(), color: Color(.indigo), width: 5.0, action:{
                        router.path.append(NavigationPathType.createTask(groupID: vm.groupInfo.id))
                    })
                }
            }
            if vm.latestTasks.count > 0 {
                ForEach(vm.latestTasks.indices, id: \.self) { index in
                    let task = vm.latestTasks[index]
                    Button(action: {
                        // タスク詳細に遷移、ポップアップで詳細表示でも可
                    }) {
                        ActiveTaskRow(taskName: task.taskName)
                    }
                    .padding(.leading, 10)
                }
            } else {
                Text("タスクを設定しましょう！")
                    .font(.callout.bold())
                    .foregroundStyle(Color.black.opacity(0.8))
                    .padding(5)
            }
            
            if vm.tasks.count > vm.latestTasks.count {
                Button(action: {
                    // タスク一覧に遷移、ポップアップで詳細表示でも可
                }) {
                    Text("他\(vm.tasks.count)のタスク")
                }
            }
        }
    }
    
    @ViewBuilder
    func makeRewardList() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                if !vm.asHost {
                    SectionLabel(text: "リワード", font: .callout.bold(), color: Color(.indigo), width: 5.0)
                } else {
                    SectionLabelWithAdd(text: "リワード", font: .callout.bold(), color: Color(.indigo), width: 5.0, action:{
                        router.path.append(NavigationPathType.createReward(groupID: vm.groupInfo.id))
                    })
                }
            }
            if vm.latestRewards.count > 0 {
                ForEach(vm.latestRewards.indices, id: \.self) { index in
                    let reward = vm.latestRewards[index]
                    Button(action: {
                        // タスク詳細に遷移、ポップアップで詳細表示でも可
                    }) {
                        PendingRewardRow(rewardName: reward.rewardName, status: "申請中")
                    }
                    .padding(.leading, 10)
                }
            } else {
                Text("リワードを設定しましょう！")
                    .font(.callout.bold())
                    .foregroundStyle(Color.black.opacity(0.8))
                    .padding(5)
            }
            
            if vm.rewards.count > vm.latestRewards.count {
                Button(action: {
                    // タスク一覧に遷移、ポップアップで詳細表示でも可
                }) {
                    Text("他\(vm.tasks.count)のタスク")
                }
            }
        }
    }
}

struct InviteMembersButton: View {
    @Binding var flag: Bool
    var body: some View {
        Button(action: {
            flag = true
        })
        {
            HStack(spacing: 5) {
                PaperPlaneIcon()
                    .frame(width: 18, height: 18)
                Text("招待する")
                    .font(.caption.bold())
            }
            .foregroundColor(Color(.indigo))
            .padding(.leading, 10)
        }
    }
}
