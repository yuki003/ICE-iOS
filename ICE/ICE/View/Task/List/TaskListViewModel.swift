//
//  TaskListViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/17.
//

import SwiftUI
import Amplify
import Combine

final class TaskListViewModel: ViewModelBase {
    // MARK: Properties
    @Published var text: String = ""
    @Published var num: Int = 0
    
    // MARK: Flags
    @Published var receiveTaskOrder: Bool = false
    @Published var navToTaskReport: Bool = false
    @Published var navToTaskHistory: Bool = false
    
    // MARK: Instances
    @Published var tasks: [Tasks]
    @Published var selectedTask: Tasks?
    
    // MARK: Validations
    
    // MARK: initializer
    init(tasks: [Tasks])
    {
        self.tasks = tasks
    }
    @MainActor
    func loadData() async {
        asyncOperation({
        })
    }
//    @MainActor
//    func taskButtonAction(_ status: BelongingTaskStatus, _ task: Tasks) {
//        selectedTask = task
//        switch status {
//        case .accept:
//            receiveTaskOrder = true
//        case .receiving:
//            navToTaskReport = true
//        case .completed:
//            navToTaskReport = true
//        }
//    }
}

