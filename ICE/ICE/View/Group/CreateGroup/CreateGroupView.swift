//
//  CreateGroupView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/31.
//

import SwiftUI
import Amplify

struct CreateGroupView: View {
    @Environment(\.asGuestKey) private var asGuest
    @StateObject var vm: CreateGroupViewModel
    var body: some View {
        VStack {
            switch vm.state {
            case .idle:
                Color.clear.onAppear { vm.state = .loading }
            case .loading:
                LoadingView().onAppear{
                    Task{
                        try await vm.loadData()
                    }
                }
            case let .failed(error):
                Text(error.localizedDescription)
            case .loaded:
                NavigationView {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 10) {
                            Text("Create Group View!!")
                        }
                        .padding(.vertical)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                            }
                        }
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarBackButtonHidden(true)
                        .alert(isPresented: $vm.alert) {
                            Alert(
                                title: Text(
                                    "エラー"
                                ),
                                message: Text(
                                    vm.alertMessage ?? "操作をやり直してください。"
                                ),
                                dismissButton: .default(
                                    Text(
                                        "閉じる"
                                    )
                                )
                            )
                        }
                    }
                }
                .navigationDestination(isPresented: $vm.flag) {
                    HomeView(vm: .init())
                }
            }
        }
    }
    
    @ViewBuilder
    func hooSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
        }
    }
}


//#Preview{
//    HomeView(vm: .init())
//}