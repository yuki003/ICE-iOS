//
//  TaskListView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/17.
//

import SwiftUI
import Amplify

struct TaskListView: View {
    @StateObject var vm: TaskListViewModel
    @StateObject var taskService: TaskService
    @EnvironmentObject var router: PageRouter
    var body: some View {
        DestinationHolderView(router: router) {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10) {
                        taskService.taskListBuilder(vm.tasks, $vm.selectedTask, $vm.navToHostTaskActions)
                    }
                    .padding(.vertical)
                    .frame(width: deviceWidth())
                }
                .refreshable {
                    Task {
                        vm.reload = true
                        await vm.loadData()
                    }
                }
            }
            .task {
                await vm.loadData()
            }
            .popupAlert(prop: $vm.apiErrorPopAlertProp)
            .userToolbar(userName: vm.userName, dismissExists: true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
}
