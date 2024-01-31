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
                        VStack(alignment: .center, spacing: 10) {
                            taskService.taskListBuilder(vm.tasks, router)
                        }
                        .padding(.vertical)
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
                    .refreshable {
                        Task {
                            vm.reload = true
//                            try await vm.reloadData()
                        }
                    }
                }
            }
            .userToolbar(state: vm.state, userName: nil, dismissExists: true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    @ViewBuilder
    func hooSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
        }
    }
}
