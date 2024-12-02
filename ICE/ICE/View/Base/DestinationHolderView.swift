//
//  DestinationHolderView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/12/11.
//

import SwiftUI

struct DestinationHolderView<Content:View>: View {
    @ObservedObject var router: PageRouter
    let content: Content

    init(router: PageRouter, @ViewBuilder content: () -> Content) {
        self.router = router
        self.content = content()
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            content
//                .navigationDestination(for: Int.self) { // - 2
//                    int in
//                    // 遷移先Viewを定義
//                }
                .navigationDestination(for: NavigationPathType.self) {
                    value in
                    switch value {
                    case .home:
                        HomeView(vm: .init())
                    case .groupDetail(let group):
                        GroupDetailView(vm: .init(groupInfo: group), taskService: .init())
                    case .createTask(let groupID):
                        CreateTaskView(vm: .init(groupID: groupID))
                    case .createGroup:
                        CreateGroupView(vm: .init())
                    case .createReward(groupID: let groupID):
                        CreateRewardsView(vm: .init(groupID: groupID))
                    case .taskList(tasks: let tasks):
                        TaskListView(vm: .init(tasks: tasks), taskService: .init())
                    case .taskReport(task: let task):
                        TaskReportView(vm: .init(task: task))
                    case .taskApproval(task: let task):
                        TaskApprovalView(vm: .init(task: task))
                    }
                }
        }
        .environmentObject(router)
    }
}
