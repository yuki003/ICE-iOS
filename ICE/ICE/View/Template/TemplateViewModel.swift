
import SwiftUI
import Amplify
import Combine

final class TemplateViewModel: ViewModelBase {
    // MARK: Properties
    @Published var text: String = ""
    @Published var num: Int = 0
    
    // MARK: Flags
    @Published var flag: Bool = false
    
    // MARK: Instances
    
    // MARK: Validations
    
    // MARK: initializer
    @MainActor
    func loadData() async {
        asyncOperation({ [self] in
        }, apiErrorHandler: { apiError in
            self.setErrorMessage(apiError)
        }, errorHandler: { error in
            self.setErrorMessage(error)
        })
    }
}
