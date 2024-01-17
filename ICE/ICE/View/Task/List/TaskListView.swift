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
                        VStack(alignment: .center, spacing: 20) {
                            TaskIcon(thumbnail: TaskType(rawValue: vm.task.iconName)!.icon, aspect: 70, selected: true)
                                .padding(.top)
                            HStack(alignment: .center, spacing: 10) {
                                Text(vm.task.taskName)
                                    .font(.body.bold())
                                    .lineLimit(2)
                                Text("\(vm.task.point.comma())pt")
                                    .font(.body.bold())
                                    .foregroundStyle(Color(.indigo))
                            }
                            GroupDescription(description: vm.task.description)
                            Divider()
                            
                            if let conditions = vm.task.condition, !conditions.isEmpty {
                                VStack(alignment: .center, spacing: 5) {
                                    SectionLabel(text: "達成条件", font: .callout.bold(), color: Color(.indigo), width: 3)
                                    ForEach(conditions.indices, id: \.self) { index in
                                        let condition = conditions[index]
//                                        ItemizedRow(name: condition!)
                                    }
                                }
                            }
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
