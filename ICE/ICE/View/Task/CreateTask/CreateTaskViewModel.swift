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
    @Published var frequencyAndPeriodic: FrequencyAndPeriodic = .init()
    var translatedFrequency: String {
        enumUtil.translateFrequencyType(frequency: frequencyAndPeriodic.frequency)
    }
    var translatedPeriodic: String? {
        enumUtil.translatePeriodicType(periodic: frequencyAndPeriodic.periodic)
    }
    let groupID: String
    
    // MARK: Flags
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
    var frequencyAndPeriodicValidation: AnyPublisher<Validation, Never> {
        $frequencyAndPeriodic
            .map { value in
                if value.frequency == .periodic, value.periodic == nil {
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
        Publishers.CombineLatest3 (
            groupNameValidation,
            frequencyAndPeriodicValidation,
            pointValidation
        )
        .map { v1, v2, v3 in
            [v1, v2, v3].allSatisfy(\.isSuccess) ? .success : .failed()
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
            self.showAlert = false
            if !self.condition.isEmpty {
                self.conditions.append(self.condition)
            }
            let task = Tasks(createUserID: self.userID, taskName: self.taskName, description: self.taskDescription.isEmpty ? nil : self.taskDescription, iconName: self.taskType.rawValue , frequencyType: self.frequencyAndPeriodic.frequency, periodicType: self.frequencyAndPeriodic.periodic, condition: self.conditions, point: self.point, groupID: self.groupID)
            try await self.apiHandler.create(task)
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
        frequencyAndPeriodic.frequency = .onlyOnce
        frequencyAndPeriodic.periodic = nil
        createComplete = false
    }
}
struct FrequencyAndPeriodic {
    var frequency: FrequencyType = .onlyOnce
    var periodic: PeriodicType?
}
