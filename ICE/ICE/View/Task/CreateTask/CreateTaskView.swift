//
//  CreateTaskView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/20.
//

import SwiftUI

struct CreateTaskView: View {
    @FocusState private var focused: FormField?
    @StateObject var vm: CreateTaskViewModel
    @State var fieldNum: String = ""
    @EnvironmentObject var router: PageRouter
    var body: some View {
        VStack {
            switch vm.state {
            case .idle:
                Color.clear.onAppear { vm.state = .loading }
            case .loading:
                LoadingView().onAppear { vm.state = .loaded }
            case let .failed(error):
                Text(error.localizedDescription)
            case .loaded:
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 20) {
                        VStack(alignment: .center, spacing: 5) {
                            // icon
                            iconSection()
                            // taskName line2
                            VStack(alignment: .center, spacing: 5) {
                                SectionLabel(text: "タスク名", font: .callout.bold(), color: Color(.indigo), width: 3)
                                UnderLineTextField(text: $vm.taskName, focused: _focused, field: FormField.name, placeHolder: "タスク名を入力")
                            }
                        }
                        // description
                        DescriptionTextEditor(description: $vm.taskDescription, focused: _focused)
                        
                        // condition
                        VStack(alignment: .center, spacing: 5) {
                            HStack(alignment: .center, spacing: 5) {
                                Rectangle()
                                    .frame(width: 3, height: 3 * 5)
                                    .foregroundStyle(Color(.indigo))
                                Text("達成条件")
                                    .font(.callout.bold())
                                    .foregroundStyle(Color(.indigo))
                                    .lineLimit(2)
                                AddSquareIcon()
                                    .frame(width: 18, height: 18)
                                    .onTapGesture {
                                        if !vm.condition.isEmpty {
                                            vm.setCondition()
                                        }
                                    }
                                Spacer()
                            }
                            if !vm.conditions.isEmpty {
                                ForEach(vm.conditions.indices, id: \.self) { index in
                                    let condition = vm.conditions[index]
                                    if !condition.isEmpty {
                                        ItemizedRow(name: condition)
                                    }
                                }
                            }
                            UnderLineTextField(text: $vm.condition, field: FormField.itemize, placeHolder: "達成条件を入力", iconName: "circle.fill")
                        }
                        // point
                        VStack(alignment: .center, spacing: 5) {
                            SectionLabel(text: "獲得ポイント数", font: .callout.bold(), color: Color(.indigo), width: 3)
                            UnderLineNumField(fieldValue: $fieldNum, num: $vm.point, field: FormField.number)
                                .validation(vm.pointValidation)
                        }
                        
                        //setting frequency
                        FrequencyPicker(label: "くりかえし", frequencyType: $vm.frequencyType)
                        
                        VStack(spacing: 10) {
                            Toggle(isOn: $vm.isLimited) {
                                SectionLabel(text: "スケジューリング", font: .callout.bold(), color: Color(.indigo), width: 3)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(.indigo)))
                            .padding(.trailing)
                            
                            if vm.isLimited {
                                PeriodPicker(start: $vm.startDate, end: $vm.endDate)
                            }
                        }
                        Spacer()
                        if !vm.createComplete {
                            EnabledFlagFillButton(label: "タスクを作成", color: Color(.jade), flag: $vm.showAlert, condition: vm.formValid.isSuccess == false)
                                .padding(.vertical)
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 20)
                    .padding(.top)
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
                    .popupTaskIconSelector(isPresented: $vm.showIconSelector, taskType: $vm.taskType)
                    .popupActionAlert(isPresented: $vm.showAlert, title: "作成しますか？",
                                      text:"""
                                           入力した内容でタスクを作成します。
                                           作成したタスクはのちに編集することもできます。
                                           """
                                      , action: { Task { try await vm.createTask()} }, actionLabel: "作成")
                    .popupDismissAndActionAlert(isPresented: $vm.createComplete, title: "タスク作成完了!!", text: "グループ画面から作ったタスクを確認できます。", dismissLabel: "グループ画面に戻る", actionLabel: "このまま続ける", action: { vm.initialization() })
                }
            }
        }
        .loading(isLoading: $vm.isLoading)
        .userToolbar(state: vm.state, userName: nil, dismissExists: true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    func iconSection() -> some View {
        Button(action: {
            vm.showIconSelector = true
        })
        {
            TaskIcon(thumbnail: vm.taskType.icon, aspect: 70, selected: true)
        }
    }
}
