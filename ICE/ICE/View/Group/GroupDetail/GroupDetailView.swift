//
//  GroupDetailView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/18.
//

import SwiftUI
import Amplify
struct GroupDetailView: View {
    @Environment(\.asGuestKey) private var asGuest
    @StateObject var vm: GroupDetailViewModel
    var body: some View {
        NavigationStack {
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
                    VStack(alignment: .center, spacing: 20) {
                        VStack(alignment: .center, spacing: 15) {
                            Text(vm.groupInfo.groupName)
                                .font(.headline.bold())
                                .foregroundStyle(Color(.indigo))
                            
                            Thumbnail(type: ThumbnailType.group, thumbnail: vm.thumbnail, aspect: 70)
                            
                            GroupDescription(description: vm.groupInfo.description)
                            
                            Divider()
                        }
                        makeMemberList()
                        makeTaskList()
                        makeRewardList()
                        
                        Spacer()
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
            }
            .userToolbar(state: vm.state, userName: nil, dismissExists: true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $vm.createTask) {
            CreateTaskView(vm: .init())
        }
    }
    
    @ViewBuilder
    func makeMemberList() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "メンバー", font: .callout.bold(), color: Color(.indigo), width: 5.0)
            HStack(spacing: 10) {
                if vm.displayUser.count > 0 {
                    ForEach(vm.displayUser.indices, id: \.self) { index in
                        let user = vm.users[index]
                        Button(action: {
                            // ユーザー詳細に遷移、ポップアップで詳細表示でも可
                        }) {
                            Thumbnail(type: ThumbnailType.user, thumbnail: vm.userThumbnails[index], aspect: 30)
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
                if asGuest {
                    SectionLabel(text: "タスク", font: .callout.bold(), color: Color(.indigo), width: 5.0)
                } else {
                    SectionLabelWithAdd(text: "タスク", font: .callout.bold(), color: Color(.indigo), width: 5.0, addFlag: $vm.createTask)
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
                if asGuest {
                    SectionLabel(text: "リワード", font: .callout.bold(), color: Color(.indigo), width: 5.0)
                } else {
                    SectionLabelWithAdd(text: "リワード", font: .callout.bold(), color: Color(.indigo), width: 5.0, addFlag: $vm.createReward)
                        .navigationDestination(isPresented: $vm.createReward, destination: {
                            // CreateRewardView(vm: .init())
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

//#Preview {
//    GroupDetailView()
//}