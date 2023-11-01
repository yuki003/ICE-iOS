
import SwiftUI
import Amplify

final class TemplateViewModel: ObservableObject {
    @Published var state: LoadingState = .idle
    @ObservedObject var auth = AmplifyAuthService()
    @ObservedObject var apiHandler = APIHandler()
    
    @Published var flag: Bool = false 
    @Published var alert: Bool = false
    @Published var alertMessage: String?
    
    @Published var createGroup: Bool = false
    @Published var belongGroup: Bool = false
    
    @Published var userID: String? = UserDefaults.standard.string(forKey: "userID")
    
    @MainActor
    func loadData() async throws {
        do {
            withAnimation(.linear) {
                state = .loaded
            }
        } catch let error as APIError {
            alertMessage = error.localizedDescription
            alert = true
            withAnimation(.linear) {
                state = .failed(error)
            }
        } catch let error {
            alertMessage = error.localizedDescription
            alert = true
            withAnimation(.linear) {
                state = .failed(error)
            }
        }
    }
}
