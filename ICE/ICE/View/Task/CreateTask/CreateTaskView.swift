//
//  CreateTaskView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/20.
//

import SwiftUI

struct CreateTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: FormField?
    @StateObject var vm: CreateTaskViewModel
    @State var fieldNum: String = ""
    @EnvironmentObject var router: PageRouter
    @State var isDelete: Bool = false
    var body: some View {
        NavigationView {
            VStack {
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
                                if let condition = vm.conditions[index], !condition.isEmpty {
                                    ItemizedRow(name: condition, font: .callout.bold(), onUnderLine: true)
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
                    HStack(spacing: 10) {
                        if vm.isEdit {
                            ActionWithFlagFillButton(label: "タスクを削除",
                                                     action: {
                                isDelete = true
                                vm.confirmTaskAlertProp.title = "削除しますか？"
                                vm.confirmTaskAlertProp.text = vm.deleteText
                                vm.completeTaskAlertProp.title = "削除完了!!"
                                vm.completeTaskAlertProp.text = vm.completeDelete
                                vm.confirmTaskAlertProp.action = vm.deleteTasks
                            },
                                                     color: Color.red, flag: $vm.confirmTaskAlertProp.isPresented)
                        }
                        ActionWithFlagFillButton(label: vm.isEdit ? "タスクを編集" : "タスクを作成", action: { vm.confirmTaskAlertProp.action = vm.createTasks }, color: Color(vm.isEdit ? .indigo : .jade), flag: $vm.confirmTaskAlertProp.isPresented, condition: vm.formValid.isSuccess == false)
                            .padding(.vertical)
                        
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
                .padding(.top)
                .frame(width: deviceWidth())
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(vm.isEdit ? "タスク編集" : "タスク作成").font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .font(.callout)
                            .foregroundColor(Color.gray)
                    }
                }
            }
            .task {
                vm.loadData()
            }
        }
        .popupTaskIconSelector(isPresented: $vm.showIconSelector, taskType: $vm.taskType)
        .popupActionAlert(prop: $vm.confirmTaskAlertProp, actionLabel: isDelete ? "削除" : vm.isEdit ? "編集" : "作成")
        .popupDismissAndActionAlert(prop: $vm.completeTaskAlertProp, dismissLabel: "戻る", actionLabel: "新規作成")
        .popupAlert(prop: $vm.apiErrorPopAlertProp)
        .loading(isLoading: $vm.isLoading)
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
