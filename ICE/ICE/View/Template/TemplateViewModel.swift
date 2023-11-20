
import SwiftUI
import Amplify

final class TemplateViewModel: ViewModelBase {
    
    @Published var flag: Bool = false
    @Published var text: String = ""
    @Published var num: Int = 0
    
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
