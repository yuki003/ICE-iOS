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
    @StateObject var taskService: TaskService
    @StateObject var rewardService: RewardService
    @EnvironmentObject var router: PageRouter
    
    @State var inviteFlag: Bool = false
    var body: some View {
        DestinationHolderView(router: router) {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 20) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: 50) {
                                VStack(alignment: .center, spacing: 10) {
                                    Text(vm.groupInfo.groupName)
                                        .font(.headline.bold())
                                        .foregroundStyle(Color(.indigo))
                                    
                                    Thumbnail(type: ThumbnailType.group, url: vm.groupInfo.thumbnailKey ?? "", aspect: 70)
                                }
                                VStack(alignment: .center, spacing: 20) {
                                    Text("ポイント")
                                        .font(.title2.bold())
                                    Text("\(vm.point)pt")
                                        .font(.title2.bold())
                                }
                            }
                            
                            GroupDescription(description: vm.groupInfo.description)
                            
                            Divider()
                        }
                        makeMemberList()
                        makeTaskList()
                        makeRewardList()
                    }
                    .padding()
                    .frame(width: deviceWidth())
                }
                .sheet(isPresented: $inviteFlag) {
                    ActivityViewController(activityItems: [vm.invitationBaseText], applicationActivities: nil)
                }
                .sheet(isPresented: $vm.navToHostTaskActions, onDismiss: {
                    Task {
                        await vm.loadData()
                    }
                }) {
                    CreateTaskView(vm: .init(groupID: vm.groupInfo.id, selectedTask: vm.selectedTask))
                }
                .sheet(isPresented: $vm.navToHostRewardsActions, onDismiss: {
                    Task {
                        await vm.loadData()
                    }
                }) {
                    CreateRewardsView(vm: .init(groupID: vm.groupInfo.id, selectedReward: vm.selectedReward))
                }
                .sheet(isPresented: $vm.navToTaskReport, onDismiss: {
                    Task {
                        await vm.loadData()
                    }
                }) {
                    if let selected = vm.selectedTask {
                        TaskReportView(vm: .init(task: selected))
                    }
                }
                .refreshable {
                    Task {
                        vm.reload = true
                        try await vm.reloadData()
                    }
                }
            }
            .loading(isLoading: $vm.isLoading)
            .loading(isLoading: $taskService.isLoading)
            .userToolbar(userName: vm.userName, dismissExists: true)
            .popupActionAlert(prop: $taskService.receiveConfirmAlertProp,
                              actionLabel: "挑戦する")
            .popupActionAlert(prop: $rewardService.applyConfirmAlertProp,
                              actionLabel: "申請する")
            .popupActionAlert(prop: $rewardService.applyCancelAlertProp,
                              actionLabel: "取り消す")
            .popupAlert(prop: $rewardService.applyRejectAlertProp)
            .popupAlert(prop: $taskService.taskReceivedAlertProp)
            .popupAlert(prop: $rewardService.rewardAppliedAlertProp)
            .popupAlert(prop: $rewardService.rewardCanceledAlertProp)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .task {
                await vm.loadData()
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
                        vm.selectedTask = nil
                        vm.navToHostTaskActions = true
                    })
                }
            }
            if vm.latestTasks.count > 0 {
                taskService.taskListBuilder(vm.latestTasks, $vm.selectedTask, vm.asHost ? $vm.navToHostTaskActions : $vm.navToTaskReport, $vm.reload)
            } else {
                Text("タスクを設定しましょう！")
                    .font(.callout.bold())
                    .foregroundStyle(Color.black.opacity(0.8))
                    .padding(5)
            }
            
            if vm.tasks.count > vm.latestTasks.count {
                Button(action: {
                    router.path.append(NavigationPathType.taskList(tasks: vm.tasks))
                }) {
                    HStack {
                        Text("他\(vm.tasks.count - vm.latestTasks.count)のタスク")
                        Image(systemName: "chevron.right")
                            .frame(width: 10, height: 10)
                        Spacer()
                    }
                    .foregroundStyle(Color.black)
                    .bold()
                }
                .padding(.leading, 10)
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
                        vm.selectedReward = nil
                        vm.navToHostRewardsActions = true
                    })
                }
            }
            if vm.latestRewards.count > 0 {
                rewardService.rewardListBuilder(vm.latestRewards, $vm.selectedReward, vm.asHost ? $vm.navToHostRewardsActions : $vm.navToRewardApply, vm.point, $vm.reload)
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
