//
//  TaskApprovalView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/02/05.
//

import SwiftUI
import Amplify

struct TaskApprovalView: View {
    @StateObject var vm: TaskApprovalViewModel
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
                        VStack(alignment: .center, spacing: 20) {
                            if !vm.reportsWithUsers.isEmpty {
                                ForEach(vm.reportsWithUsers.indices, id:\.self){ index in
                                    let reportWithUser = vm.reportsWithUsers[index]
                                    ApprovalReportRow(showImage: $vm.showImage, selectedImage: $vm.selectedImage, comment: $vm.comment, task: vm.task, reportWithUser: reportWithUser, approvalAction: {
                                        vm.selectedReport = reportWithUser.report
                                        vm.approve = true
                                    }, rejectAction: {
                                        vm.selectedReport = reportWithUser.report
                                        vm.reject = true
                                    })
                                }
                            }
                        }
                        .padding(.vertical)
                        .frame(width: deviceWidth())
                        .alert(isPresented: $vm.alert) {
                            Alert(
                                title: Text("エラー"),
                                message: Text(vm.alertMessage ?? "操作をやり直してください。"),
                                dismissButton: .default(Text("閉じる"))
                            )
                        }
                    }
                }
            }
            .dismissToolbar {
                ToolbarItem(placement: .principal) {
                    HStack(alignment: .center, spacing: 10) {
                        TaskIcon(thumbnail: TaskType(rawValue: vm.task.iconName)!.icon, aspect: 30, selected: true)
                        Text(vm.task.taskName)
                            .font(.callout.bold())
                            .foregroundStyle(Color.black)
                        Spacer()
                        Text("\(vm.task.point.comma())pt")
                            .font(.callout.bold())
                            .foregroundStyle(Color(.indigo))
                            .padding(.trailing, 10)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .loading(isLoading: $vm.isLoading)
            .popupActionAlert(isPresented: $vm.approve, text: "レポートを承認しますか？", action: { await vm.reportApprove() }, actionLabel: "承認")
            .popupActionAlert(isPresented: $vm.reject, text: "レポートを却下しますか？", action: { await vm.reportReject() }, actionLabel: "却下")
            .popupDismissAlert(isPresented: $vm.approveComplete, title: "承認完了！", text: "ポイントがユーザーに付与されました。", buttonLabel: "戻る")
            .popupDismissAlert(isPresented: $vm.rejectComplete, title: "却下しました", text: "レポートを却下しました。次の報告を待ちましょう。", buttonLabel: "戻る")
            .popupImage(isPresented: $vm.showImage, url: vm.selectedImage)
        }
    }
    
    @ViewBuilder
    func hooSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
        }
    }
}
