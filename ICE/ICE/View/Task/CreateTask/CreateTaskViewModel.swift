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
                                                                          """
)
    var translatedFrequency: String {
        enumUtil.translateFrequencyType(frequency: frequencyType)
    }
    let groupID: String
    
    // MARK: Flags
    @Published var isLimited: Bool = false
    @Published var showIconSelector: Bool = false
    @Published var createComplete: Bool = false
    
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
    func createTask() async throws {
        asyncOperation({
            self.createTaskAlertProp.isPresented = false
            if !self.condition.isEmpty {
                self.conditions.append(self.condition)
            }
            var task = Tasks(createUserID: self.userID, taskName: self.taskName, description: self.taskDescription.isEmpty ? nil : self.taskDescription, iconName: self.taskType.rawValue , frequencyType: self.frequencyType, condition: self.conditions, point: self.point, groupID: self.groupID, hasPendingReport: false)
            
            if self.isLimited {
                task.startDate = Temporal.DateTime(self.startDate)
                task.endDate = Temporal.DateTime(self.endDate)
            }
            
            try await self.apiHandler.create(task, keyName: "\(self.groupID)-tasks")
            self.createComplete = true
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
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
        createComplete = false
    }
}
