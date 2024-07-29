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
    @State var approveAlertProp: PopupAlertProperties = .init(text: "レポートを承認しますか？")
    @State var rejectAlertProp: PopupAlertProperties = .init(text: "レポートを却下しますか？")
    var body: some View {
        DestinationHolderView(router: router) {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 20) {
                        if !vm.reportsWithUsers.isEmpty {
                            ForEach(vm.reportsWithUsers.indices, id:\.self){ index in
                                let reportWithUser = vm.reportsWithUsers[index]
                                ApprovalReportRow(showImage: $vm.showImage, selectedImage: $vm.selectedImage, comment: $vm.comment, task: vm.task, reportWithUser: reportWithUser, approvalAction: {
                                    vm.selectedReport = reportWithUser.report
                                    approveAlertProp.action = vm.reportApprove
                                    approveAlertProp.isPresented = true
                                }, rejectAction: {
                                    vm.selectedReport = reportWithUser.report
                                    rejectAlertProp.action = vm.reportReject
                                    rejectAlertProp.isPresented = true
                                })
                            }
                        }
                    }
                    .padding(.vertical)
                    .frame(width: deviceWidth())
                }
            }
            .task {
                await vm.loadData()
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
            .popupActionAlert(prop: $approveAlertProp, actionLabel: "承認")
            .popupActionAlert(prop: $rejectAlertProp, actionLabel: "却下")
            .popupDismissAlert(prop: $vm.approvedAlertProp)
            .popupDismissAlert(prop: $vm.rejectedAlertProp)
            .popupAlert(prop: $vm.apiErrorPopAlertProp)
            .popupImage(isPresented: $vm.showImage, url: vm.selectedImage)
        }
    }
    
    @ViewBuilder
    func hooSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
        }
    }
}
