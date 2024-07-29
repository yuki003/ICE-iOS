//
//  TaskReportView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/01/31.
//

import SwiftUI
import Amplify
import Kingfisher

struct TaskReportView: View {
    @StateObject var vm: TaskReportViewModel
    @EnvironmentObject var router: PageRouter
    @FocusState private var focused: FormField?
    @State var imageDeleteAlertProp: PopupAlertProperties = .init(text: "画像を削除しますか？")
    @State private var isShowCameraView: Bool = false
    @State private var isShowPhotoLibrary: Bool = false
    @State private var isShowConfirmation: Bool = false
    @State private var selectIndex: Int?
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
                            TaskDetailSection(task: vm.task)
                            Divider()
                            reportSection()
                        }
                        .padding()
                        .frame(width: screenWidth())
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
                            try await vm.loadData()
                        }
                    }
                }
            }
            .frame(width: deviceWidth())
            .fullScreenCover(isPresented: $isShowCameraView) {
                CameraView(image: $vm.image).ignoresSafeArea()
            }
            .sheet(isPresented: $isShowPhotoLibrary, content: {
                ImagePicker(sourceType: .photoLibrary, selectedImage: $vm.image)
            })
            .onChange(of: vm.image) { image in
                if image.isNotEmpty() {
                    vm.images.append(image)
                    vm.image = UIImage()
                }
            }
            .userToolbar(state: vm.state, userName: nil, dismissExists: true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .loading(isLoading: $vm.isLoading)
            .popupActionAlert(prop: $vm.submitAlertProp, actionLabel: "報告")
            .popupActionAlert(prop: $vm.deleteAlertProp, actionLabel: "取り消す")
            .popupActionAlert(prop: $imageDeleteAlertProp, actionLabel: "削除")
            .popupDismissAlert(prop: $vm.completedSubmitAlertProp)
            .popupAlert(prop: $vm.apiErrorPopAlertProp)
            .confirmationDialog("", isPresented: $isShowConfirmation) {
                Button("カメラで撮影"){
                    isShowCameraView = true
                }
                Button("ライブラリから選択"){
                    isShowPhotoLibrary = true
                }
                Button("キャンセル", role: .cancel) {
                    isShowConfirmation.toggle()
                }
            }
        }
    }
    
    @ViewBuilder
    func reportSection() -> some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(alignment: .center, spacing: 20) {
                ForEach(vm.images.indices, id:\.self){ index in
                    let image = vm.images[index]
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        Button(action: {
                            selectIndex = index
                            imageDeleteAlertProp.action = {
                                if let index = selectIndex {
                                    vm.images.remove(at: index)
                                }
                            }
                            imageDeleteAlertProp.isPresented = true
                        })
                        {
                            XMarkCircleFillIcon()
                                .background(Color.white)
                                .foregroundStyle(Color(.indigo))
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                        }
                        .offset(x: 40, y: 40)
                    }
                }
                if vm.images.count < 3, vm.taskReports?.status != .approved {
                    Button(action:{
                        isShowConfirmation = true
                    })
                    {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color(.indigo))
                            .frame(width: 80, height: 80)
                            .overlay {
                                CameraOnRectangleIcon()
                                    .foregroundColor(Color(.indigo))
                                    .frame(width: 60, height: 55)
                            }
                    }
                }
            }
                if let taskReports = vm.taskReports, let reports = taskReports.reports {
                    SectionLabel(text: "報告内容", font: .footnote.bold(), color: Color(.jade), width: 3)
                    HStack {
                        Thumbnail(type: ThumbnailType.user, aspect: 30)
                            .padding(.leading, 50)
                        Spacer()
                        if let rejectedComment = vm.taskReports?.rejectedComment, rejectedComment.count > 0 {
                            Thumbnail(type: ThumbnailType.user, aspect: 30)
                                .padding(.trailing, 50)
                        }
                    }
                    .frame(width: screenWidth())
                    ForEach(reports.indices, id:\.self) { index in
                        let report = reports[index]
                        if let leftText = report {
                            HStack(spacing: 10) {
                                Text(leftText)
                                    .font(.footnote.bold())
                                    .foregroundStyle(Color.black)
                                Spacer()
                            }
                        }
                        if let rejectedComment = vm.taskReports?.rejectedComment, rejectedComment.count > index {
                            let rejectedComment = taskReports.rejectedComment?[index]
                            if let rightText = rejectedComment {
                                HStack(spacing: 10) {
                                    Spacer()
                                    Text(rightText)
                                        .font(.footnote.bold())
                                        .foregroundStyle(Color.black)
                                }
                            }
                        }
                    }
                    if taskReports.status == .approved {
                        HStack(spacing: 10) {
                            Spacer()
                            Text(taskReports.approvedComment!)
                                .font(.footnote.bold())
                                .foregroundStyle(Color.black)
                        }
                        Text("\(taskReports.updatedAt!.foundationDate.toFormat("yyyy/MM/dd HH:mm"))に承認されました")
                            .font(.callout.bold())
                            .foregroundStyle(Color(.indigo))
                    } else if taskReports.status == .deleted {
                            Text("\(taskReports.updatedAt!.foundationDate.toFormat("yyyy/MM/dd HH:mm"))に取り消しされました")
                                .font(.callout.bold())
                                .foregroundStyle(Color(.jade))
                    } else {
                        DescriptionTextEditor(description: $vm.report, focused: _focused, placeholder: "タスク報告を書こう")
                    }
                }
            
            if vm.taskReports == nil {
                DescriptionTextEditor(description: $vm.report, focused: _focused, placeholder: "タスク報告を書こう")
            }
            if vm.taskReports == nil {
                ActionWithFlagFillButton(label: "報告", action: {vm.submitAlertProp.action = vm.repotTask }, color: Color(.indigo), flag: $vm.submitAlertProp.isPresented, condition: !(vm.taskReports == nil || vm.taskReports?.status == ReportStatus.rejected))
                    .padding(.vertical)
            } else if vm.taskReports?.status == ReportStatus.rejected {
                FlagFillButton(label: "再報告", color: Color(.indigo), flag: $vm.submitAlertProp.isPresented)
                    .padding(.vertical)
            } else if vm.taskReports?.status == ReportStatus.pending {
                HStack(spacing: 20) {
                    ActionWithFlagFillButton(label: "取り消す", action: { vm.deleteAlertProp.action = vm.repotTask}, color: Color(.indigo), flag: $vm.deleteAlertProp.isPresented)
                        .padding(.vertical)
                    FlagFillButton(label: "編集する", color: Color(.indigo), flag: $vm.submitAlertProp.isPresented)
                        .padding(.vertical)
                }
            }
        }
    }
}

struct TaskDetailSection: View {
    let task: Tasks
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(alignment: .center, spacing: 10) {
                TaskIcon(thumbnail: TaskType(rawValue: task.iconName)!.icon, aspect: 30, selected: true)
                Text(task.taskName)
                    .font(.callout.bold())
                    .foregroundStyle(Color.black)
                Spacer()
                Text("\(task.point.comma())pt")
                    .font(.callout.bold())
                    .foregroundStyle(Color(.indigo))
                    .padding(.trailing, 10)
            }
            if let description = task.description {
                HStack {
                    Text(description)
                        .font(.footnote.bold())
                        .foregroundStyle(Color.black)
                    Spacer()
                }
            }
            if let conditions = task.condition, !conditions.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    SectionLabel(text: "達成条件", font: .footnote.bold(), color: Color(.jade), width: 3)
                    ForEach(conditions.indices, id: \.self){ index in
                        if let condition = conditions[0], !condition.isEmpty {
                            ItemizedRow(name: condition, font: .footnote.bold())
                                .foregroundStyle(Color.black)
                        }
                    }
                }
            }
            if task.startDate != nil || task.frequencyType != .onlyOnce {
                VStack(alignment: .leading, spacing: 5) {
                    SectionLabel(text: "情報", font: .footnote.bold(), color: Color(.jade), width: 3)
                    if let end = task.endDate {
                        Text("\(task.startDate!.foundationDate.toFormat("yyyy/MM/dd"))から\(end.foundationDate.toFormat("yyyy/MM/dd"))まで")
                            .font(.footnote.bold())
                            .foregroundStyle(Color.black)
                    }
                    if task.frequencyType != .onlyOnce {
                        Text("\(EnumUtility().translateFrequencyType(frequency: task.frequencyType))チャレンジできます")
                            .font(.footnote.bold())
                            .foregroundStyle(Color.black)
                    }
                }
            }
        }
    }
}
