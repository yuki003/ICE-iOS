//
//  CreateTaskViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/20.
//

import SwiftUI
import Amplify
import Combine

final class CreateTaskViewModel: ViewModelBase {
    // MARK: Properties
    @Published var taskType: TaskType = .defaultIcon
    @Published var taskName: String = ""
    @Published var taskDescription: String = ""
    @Published var condition: String = ""
    @Published var conditions: [String?] = []
    @Published var point: Int = 0
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var frequencyType: FrequencyType = .onlyOnce
    @Published var hasPendingReport: Bool = false
    var isEdit: Bool {
        selectedTask != nil
    }
    @Published var confirmTaskAlertProp: PopupAlertProperties = .init()
    var confirmTitle: String {
        isEdit ? "編集しますか？" :  "作成しますか？"
    }
    
    var confirmText: String {
        isEdit ? editText  : createText
    }
    let createText = """
                     入力した内容でタスクを作成します。
                     作成したタスクはのちに編集することもできます。
                     """
    let editText = """
                   入力した内容でタスクを作成します。
                   作成したタスクはのちに編集することもできます。
                   """
    let deleteText = """
                   タスクを削除します。
                   削除したタスクは元に戻すことができません。
                   """
    
    var completeTitle: String {
        isEdit ? "編集完了!!" : "作成完了!!"
    }
    
    var completeText: String {
        isEdit ? completeEdit : completeCreate
    }
    
    let completeCreate = "グループ画面から作ったタスクを確認できます。"
    let completeEdit = "グループ画面から編集したタスクを確認できます。"
    let completeDelete = "タスクを削除しました。"
    
    @Published var completeTaskAlertProp: PopupAlertProperties = .init()
    
    var translatedFrequency: String {
        enumUtil.translateFrequencyType(frequency: frequencyType)
    }
    let groupID: String
    var selectedTask: Tasks?
    
    // MARK: Flags
    @Published var isLimited: Bool = false
    @Published var showIconSelector: Bool = false
    
    // MARK: Validations
    var groupNameValidation: AnyPublisher<Validation, Never> {
        $taskName
            .dropFirst()
            .map { value in
                if value.isEmpty {
                    return .failed()
                }
                return .success
            }
            .eraseToAnyPublisher()
    }
    var pointValidation: AnyPublisher<Validation, Never> {
        $point
            .dropFirst()
            .map { value in
                if value == 0 {
                    return .failed()
                }
                if value < 0 {
                    return .failed(message: "マイナス値は設定できません")
                }
                return .success
            }
            .eraseToAnyPublisher()
    }
    
    var createValidation: AnyPublisher<Validation, Never> {
        Publishers.CombineLatest (
            groupNameValidation,
            pointValidation
        )
        .map { v1, v2 in
            [v1, v2].allSatisfy(\.isSuccess) ? .success : .failed()
        }
        .eraseToAnyPublisher()
    }
    
    private var cancellables: Set<AnyCancellable> = []
    // MARK: Initializer
    init(groupID: String, selectedTask: Tasks? = nil)
    {
        self.groupID = groupID
        self.selectedTask = selectedTask
        super.init()
        self.createValidation
            .receive(on: RunLoop.main)
            .assign(to: \.formValid, on: self)
            .store(in: &publishers)
        confirmTaskAlertProp.text = confirmText
        confirmTaskAlertProp.title = confirmTitle
        completeTaskAlertProp.text = completeText
        completeTaskAlertProp.title = completeTitle
    }
    
    @MainActor
    func loadData() {
        if let selected = selectedTask {
            taskName = selected.taskName
            taskDescription = selected.description ?? ""
            taskType = TaskType.init(type: selected.iconName)
            frequencyType = selected.frequencyType
            conditions = selected.condition ?? []
            point = selected.point
            hasPendingReport = selected.hasPendingReport
            
        }
    }
    
    @MainActor
    func createTasks() async throws {
        asyncOperation({ [self] in
            isLoading = true
            defer { isLoading = false }
            confirmTaskAlertProp.isPresented = false
            if !condition.isEmpty {
                conditions.append(condition)
            }
            var task: Tasks
            if let selected = selectedTask {
                task = selected
                task.iconName = taskType.rawValue
                task.taskName = taskName
                task.description = taskDescription
                task.frequencyType = frequencyType
                task.condition = conditions
                task.point = point
                if isLimited {
                    task.startDate = Temporal.DateTime(startDate)
                    task.endDate = Temporal.DateTime(endDate)
                }
                try await apiHandler.update(task, keyName: "\(groupID)-tasks")
            } else {
                task = Tasks(createUserID: userID, taskName: taskName, description: taskDescription.isEmpty ? nil : taskDescription, iconName: taskType.rawValue , frequencyType: frequencyType, condition: conditions, point: point, groupID: groupID, hasPendingReport: hasPendingReport)
                
                if isLimited {
                    task.startDate = Temporal.DateTime(startDate)
                    task.endDate = Temporal.DateTime(endDate)
                }
                try await apiHandler.create(task, keyName: "\(groupID)-tasks")
            }
            completeTaskAlertProp.action = initialization
            completeTaskAlertProp.isPresented = true
        })
    }
    
    @MainActor
    func deleteTasks() async throws {
        asyncOperation({ [self] in
            isLoading = true
            defer { isLoading = false }
            try await apiHandler.delete(selectedTask!, keyName: "\(groupID)-tasks")
            completeTaskAlertProp.action = initialization
            completeTaskAlertProp.isPresented = true
        })
    }
    
    @MainActor
    func setCondition() {
        conditions.append(condition)
        condition = ""
    }
    
    @MainActor
    func initialization() {
        taskType = .defaultIcon
        taskName = ""
        taskDescription = ""
        condition = ""
        conditions = []
        point = 0
        frequencyType = .onlyOnce
    }
}
