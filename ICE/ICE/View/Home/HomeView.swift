//
//  HomeView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/19.
//

import SwiftUI
import Amplify

struct HomeView: View {
    @StateObject var vm: HomeViewModel
    @ObservedObject var auth = AmplifyAuthService()
    @StateObject var router = PageRouter()
    
    var body: some View {
        DestinationHolderView(router: router) {
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
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .center, spacing: 10) {
                            CurrentActivityNotice(message: "test notice", isShowNotice: $vm.isShowNotice, nav: $vm.navNotice)
                                .padding(.top)
                            currentActivitySection()
                            if vm.asHost {
                                hostGroupSection()
                                    .padding(.top, 10)
                            }
                            belongingGroupSection()
                                .padding(.top, 10)
                        }
                        .frame(width: deviceWidth())
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
                    .refreshable {
                        Task{
                            vm.reload = true
                            try await vm.loadData()
                        }
                    }
                }
                SignOutButton(auth: auth)
            }
            .userToolbar(state: vm.state, userName: vm.userInfo?.userName ?? "ユーザー")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                vm.state = .idle
            }
        }
    }
    @ViewBuilder
    func currentActivitySection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
        }
        .padding(.vertical)
        .padding(.horizontal, 15)
        .frame(maxWidth: screenWidth(), minHeight: 100, maxHeight: .infinity, alignment: .leading)
        .roundedSection(color: Color(.jade))
    }
    @ViewBuilder
    func hostGroupSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Text("自分のグループ")
                AddButton(action: {
                    router.path.append(NavigationPathType.createGroup)
                })
                .frame(width: 18, height: 18)
            }
            .padding(.leading, 40)
            .font(.callout.bold())
            .foregroundStyle(Color(.indigo))
            if !vm.hostGroups.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(vm.hostGroups.indices, id: \.self) { index in
                            let group = vm.hostGroups[index]
                            Button(action: {
                                vm.selectedGroup = group
                                router.path.append(NavigationPathType.groupDetail(group: group))
                            })
                            {
                                HomeGroupCard(group: group, url: group.thumbnailKey ?? "" , color: Color(.indigo))
                                    .padding(.vertical, 5)
                                /// イカしたスクロールを実装するのでpaddingで暫定対応
                                    .padding(.leading, index == 0 ? 40 : 0)
                            }
                        }
                    }
                }
            } else {
                Text("あなたのグループを作成してみましょう！")
                    .font(.callout.bold())
                    .foregroundStyle(Color.black.opacity(0.8))
                    .padding(5)
                    .frame(width: screenWidth(), height: 100, alignment: .center)
                    .roundedSection(color: Color(.jade))
                /// イカしたスクロールを実装するのでpaddingで暫定対応
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: deviceWidth(), minHeight: 150, maxHeight: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    func belongingGroupSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Text("所属しているグループ")
                AddButton(action: {
                    router.path.append(NavigationPathType.createGroup)
                })
                .frame(width: 18, height: 18)
            }
            .padding(.leading, 40)
            .font(.callout.bold())
            .foregroundStyle(Color(.indigo))
            // group switchable
            if !vm.belongingGroups.isEmpty {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(vm.belongingGroups.indices, id: \.self) { index in
                            let group = vm.belongingGroups[index]
                            Button(action: {
                                vm.selectedGroup = group
                                router.path.append(NavigationPathType.groupDetail(group: group))
                            })
                            {
                                HomeGroupCard(group: group, url: group.thumbnailKey ?? "" , color: Color(.indigo))
                                    .padding(.vertical, 5)
                                /// イカしたスクロールを実装するのでpaddingで暫定対応
                                    .padding(.leading, index == 0 ? 40 : 0)
                            }
                        }
                    }
                }
            } else {
                Text("所属しているグループがありません")
                    .font(.callout.bold())
                    .foregroundStyle(Color.black.opacity(0.8))
                    .padding(5)
                    .frame(width: screenWidth(), height: 100, alignment: .center)
                    .roundedSection(color: Color(.jade))
                    .padding(.horizontal, 40)
            }
        }
        .frame(maxWidth: deviceWidth(), minHeight: 150, maxHeight: .infinity, alignment: .leading)
    }
}
//#Preview{
//    HomeView(vm: .init())
//}
