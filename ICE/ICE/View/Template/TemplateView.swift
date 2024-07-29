import SwiftUI
import Amplify

struct TemplateView: View {
    @StateObject var vm: TemplateViewModel
    @EnvironmentObject var router: PageRouter
    var body: some View {
        DestinationHolderView(router: router) {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10) {
                    }
                    .padding(.vertical)
                    .frame(width: deviceWidth())
                }
                .refreshable {
                    Task {
                        vm.reload = true
                        //                            try await vm.reloadData()
                    }
                }
            }
            .task {
                await vm.loadData()
            }
            .popupAlert(prop: $vm.apiErrorPopAlertProp)
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
