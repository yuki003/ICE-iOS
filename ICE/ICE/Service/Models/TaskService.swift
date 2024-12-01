//
//  TaskService.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/19.
//

import Foundation
import SwiftUI

final class TaskService: ViewModelBase {
    @Published var selectedTask: Tasks?
    @Published var navToTaskReport: Bool = false
    @Published var navToTaskHistory: Bool = false
    @Published var navToTaskEdit: Bool = false
    @Published var navToTaskInsight: Bool = false
    @Published var receiveConfirmAlertProp: PopupAlertProperties = .init(title:"このタスクに挑戦しますか？")
    @Published var taskReceivedAlertProp: PopupAlertProperties = .init(title: "タスクを受注しました！", text: "タスクを完了してポイントをもらおう！")

    
    override init() {
        super.init()
    }
    
    @MainActor
    func receiveTaskOrder(groupID: String) async {
        asyncOperation({ [self] in
            if let selectedTask = selectedTask  {
                var selectedTask = selectedTask
                if let receivingUserID = selectedTask.receivingUserIDs, !receivingUserID.contains(where: { $0 == userID}) {
                    selectedTask.receivingUserIDs?.append(userID)
                } else {
                    selectedTask.receivingUserIDs = [userID]
                }
                try await apiHandler.update(selectedTask, keyName: "\(groupID)-tasks")
            }
            taskReceivedAlertProp.isPresented = true
        })
    }
    
    @ViewBuilder
    func taskListBuilder(_ taskList:[Tasks], _ selected: Binding<Tasks?>, _ navTo: Binding<Bool>, _ reload: Binding<Bool>) -> some View {
        ForEach(taskList.indices, id: \.self) { index in
            let task = taskList[index]
            let status = TaskStatus.init(task)
            TaskRow(task: task, selected: selected, navTo: navTo, reload: reload, action: {
                self.selectedTask = task
                self.receiveConfirmAlertProp.action = {Task { await self.receiveTaskOrder(groupID: task.groupID)}}
                self.receiveConfirmAlertProp.isPresented = true
            }, status: status)
            .padding(.leading, 10)
        }
    }
}
