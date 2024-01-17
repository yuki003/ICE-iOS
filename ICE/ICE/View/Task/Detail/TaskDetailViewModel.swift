//
//  TaskDetailViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/17.
//

import SwiftUI
import Amplify
import Combine

final class TaskDetailViewModel: ViewModelBase {
    // MARK: Properties
    @Published var text: String = ""
    @Published var num: Int = 0
    
    // MARK: Flags
    @Published var flag: Bool = false
    
    // MARK: Instances
    
    // MARK: Validations
    
    // MARK: initializer
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

