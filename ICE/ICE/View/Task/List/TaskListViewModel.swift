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
    @Published var flag: Bool = false
    
    // MARK: Instances
    @Published var tasks: [Tasks]
    
    // MARK: Validations
    
    // MARK: initializer
    init(tasks: [Tasks])
    {
        self.tasks = tasks
    }
    @MainActor
    func loadData() async throws {
        asyncOperation({
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
}

