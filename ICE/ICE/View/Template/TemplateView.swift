import SwiftUI
import Amplify

struct TemplateView: View {
    @StateObject var vm: TemplateViewModel
    @EnvironmentObject var router: PageRouter
    var body: some View {
        DestinationHolderView(router: router) {
            VStack {
                switch vm.state {
                case .idle:
                    Color.clear.onAppear { vm.state = .loading }
                case .loading:
                    LoadingView().onAppear{
                        Task {
                            try await vm.loadData()
                        }
                    }
                case let .failed(error):
                    Text(error.localizedDescription)
                case .loaded:
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 10) {
                        }
                        .padding(.vertical)
                        .frame(width: deviceWidth())
                        .alert(isPresented: $vm.ErrorAlert) {
                            Alert(
                                title: Text("エラー"),
                                message: Text(vm.alertMessage ?? "操作をやり直してください。"),
                                dismissButton: .default(Text("閉じる"))
                            )
                        }
                    }
                    .refreshable {
                        Task {
                            vm.reload = true
//                            try await vm.reloadData()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
    }
    
    @ViewBuilder
    func hooSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
        }
    }
}
