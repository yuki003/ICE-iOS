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
    @Published var receiveConfirmation: Bool = false
    @Published var taskReceived: Bool = false
    @Published var navToTaskReport: Bool = false
    @Published var navToTaskHistory: Bool = false
    @Published var navToTaskEdit: Bool = false
    @Published var navToTaskInsight: Bool = false
    
    @MainActor
    func receiveTaskOrder(groupID: String) async throws {
        asyncOperation({ [self] in
            if let selectedTask = selectedTask  {
                var selectedTask = selectedTask
                if let receivingUserID = selectedTask.receivingUserIDs, !receivingUserID.contains(where: { $0 == userID}) {
                    selectedTask.receivingUserIDs?.append(userID)
                } else {
                    selectedTask.receivingUserIDs = [userID]
                }
                var newList = try self.apiHandler.decodeUserDefault(modelType: [Tasks].self, key: "\(groupID)-tasks")?.filter({$0.id != selectedTask.id})
                apiHandler.replaceUserDefault(models: newList ?? [], keyName: "\(groupID)-tasks")
                try await apiHandler.update(selectedTask, keyName: "\(groupID)-tasks")
            }
            taskReceived = true
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
    @MainActor
    func applyTaskCompleted() async throws {
    }
    @MainActor
    func cancelApplyTask() async throws {
    }
    
//    @MainActor
//    func belongingUserAction(_ status: BelongingTaskStatus, _ task: Tasks, _ router: PageRouter) {
//        selectedTask = task
//        switch status {
//        case .accept:
//            receiveConfirmation = true
//        case .receiving:
//            navToTaskReport = true
//            print("navToTaskReport")
//            // router.path
//        case .completed:
//            navToTaskReport = true
//            print("navToTaskReport")
//            // router.path
//        }
//    }
    
//    @MainActor
//    func hostUserTaskAction(_ hostActionType: HostTaskActionType, _ task: Tasks, _ router: PageRouter) {
//        selectedTask = task
//        switch hostActionType {
//        case .edit:
//            navToTaskEdit = true
//            print("navToTaskEdit")
//            // router.path
//        case .insight:
//            navToTaskInsight = true
//            print("navToTaskInsight")
//            // router.path
//        }
//    }
//    
    @ViewBuilder
    func taskListBuilder(_ taskList:[Tasks], _ router: PageRouter) -> some View {
        ForEach(taskList.indices, id: \.self) { index in
            let task = taskList[index]
            var status: BelongingTaskStatus {
                if let receivingUserIDs = task.receivingUserIDs, (receivingUserIDs.contains(where: { $0 == self.userID}) || self.asHost) {
                    return .receiving
                } else if let completedUserIDs = task.rejectedUserIDs, completedUserIDs.contains(where: { $0 == self.userID}) {
                    return .rejected
                } else if let completedUserIDs = task.completedUserIDs, completedUserIDs.contains(where: { $0 == self.userID}) {
                    return .completed
                } else {
                    return .accept
                }
            }
            TaskRow(task: task, action: {
                self.selectedTask = task
                self.receiveConfirmation = true
            }, asHost: self.asHost, status: status)
            .padding(.leading, 10)
        }
    }
}
