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
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 10) {
                        if vm.asHost {
                            hostGroupSection()
                                .padding(.top, 10)
                        }
                        belongingGroupSection()
                            .padding(.top, 10)
                    }
                    .frame(width: deviceWidth())
                }
                .refreshable {
                    Task{
                        vm.reload = true
                        await vm.loadData()
                    }
                }
                SignOutButton(auth: auth)
            }
            .popupAlert(prop: $vm.apiErrorPopAlertProp)
            .userToolbar(userName: vm.userName)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .task {
                await vm.loadData()
            }
        }
    }
    
    @ViewBuilder
    func hostGroupSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Text("自分のグループ")
                if vm.asHost {
                    AddButton(action: {
                        router.path.append(NavigationPathType.createGroup)
                    })
                    .frame(width: 18, height: 18)
                }
            }
            .padding(.leading)
            .font(.callout.bold())
            .foregroundStyle(Color(.indigo))
            if let hostGroups = vm.hostGroups, !hostGroups.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(hostGroups.indices, id: \.self) { index in
                            let group = hostGroups[index]
                            Button(action: {
                                vm.selectedGroup = group
                                router.path.append(NavigationPathType.groupDetail(group: group))
                            })
                            {
                                HomeGroupCard(group: group, url: group.thumbnailKey ?? "" , color: Color(.indigo))
                                    .padding(.vertical, 5)
                                /// イカしたスクロールを実装するのでpaddingで暫定対応
                                    .padding(.leading, index == 0 ? 16 : 0)
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
                    .roundedBorder(color: Color(.jade))
                /// イカしたスクロールを実装するのでpaddingで暫定対応
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: deviceWidth(), minHeight: 150, maxHeight: .infinity, alignment: .leading)
        .loadingSkeleton(object: vm.hostGroups)
    }
    
    @ViewBuilder
    func belongingGroupSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Text("所属しているグループ")
                if vm.asHost {
                    AddButton(action: {
                        router.path.append(NavigationPathType.createGroup)
                    })
                    .frame(width: 18, height: 18)
                }
            }
            .padding(.leading)
            .font(.callout.bold())
            .foregroundStyle(Color(.indigo))
            // group switchable
            if let belongingGroups = vm.belongingGroups, !belongingGroups.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(belongingGroups.indices, id: \.self) { index in
                            let group = belongingGroups[index]
                            Button(action: {
                                vm.selectedGroup = group
                                router.path.append(NavigationPathType.groupDetail(group: group))
                            })
                            {
                                HomeGroupCard(group: group, url: group.thumbnailKey ?? "" , color: Color(.indigo))
                                    .padding(.vertical, 5)
                                /// イカしたスクロールを実装するのでpaddingで暫定対応
                                    .padding(.leading, index == 0 ? 16 : 0)
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
                    .roundedBorder(color: Color(.jade))
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: deviceWidth(), minHeight: 150, maxHeight: .infinity, alignment: .leading)
        .loadingSkeleton(object: vm.belongingGroups)
    }
}
//#Preview{
//    HomeView(vm: .init())
//}
