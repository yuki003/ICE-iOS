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
    @Published var conditions: [String] = []
    @Published var point: Int = 0
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var frequencyType: FrequencyType = .onlyOnce
    @Published var createTaskAlertProp: PopupAlertProperties = .init(title: "作成しますか？",
                                                                     text:"""
                                                                          入力した内容でタスクを作成します。
                                                                          作成したタスクはのちに編集することもできます。
                                                                          """)

@Published var createdTaskAlertProp: PopupAlertProperties = .init(title: "作成完了!!", text: "グループ画面から作ったタスクを確認できます。")
    var translatedFrequency: String {
        enumUtil.translateFrequencyType(frequency: frequencyType)
    }
    let groupID: String
    
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
    init(groupID: String)
    {
        self.groupID = groupID
        super.init()
        self.createValidation
            .receive(on: RunLoop.main)
            .assign(to: \.formValid, on: self)
            .store(in: &publishers)
    }
    
    @MainActor
    func createTasks() async throws {
        isLoading = true
        defer { isLoading = false }
        asyncOperation({ [self] in
            createTaskAlertProp.isPresented = false
            if !condition.isEmpty {
                conditions.append(condition)
            }
            var task = Tasks(createUserID: userID, taskName: taskName, description: taskDescription.isEmpty ? nil : taskDescription, iconName: taskType.rawValue , frequencyType: frequencyType, condition: conditions, point: point, groupID: groupID, hasPendingReport: false)
            
            if isLimited {
                task.startDate = Temporal.DateTime(startDate)
                task.endDate = Temporal.DateTime(endDate)
            }
            
            try await apiHandler.create(task, keyName: "\(groupID)-tasks")
            createdTaskAlertProp.action = initialization
            createdTaskAlertProp.isPresented = true
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
        createdTaskAlertProp.isPresented = false
    }
}
