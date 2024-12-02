//
//  CreateRewardsView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/12/13.
//

import SwiftUI
import Amplify

struct CreateRewardsView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: FormField?
    @StateObject var vm: CreateRewardsViewModel
    @State var fieldNum: String = ""
    @State var isDelete: Bool = false
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .center, spacing: 20) {
                        VStack(alignment: .center, spacing: 5) {
                            // thumbnail
                            RewardImageSelectSection(showImagePicker: $vm.showImagePicker, thumbnailKey: vm.thumbnailKey, image: vm.image)
                            // rewardName
                            VStack(alignment: .center, spacing: 5) {
                                SectionLabel(text: "リワード名", font: .callout.bold(), color: Color(.indigo), width: 3)
                                UnderLineTextField(text: $vm.rewardName, focused: _focused, field: FormField.name, placeHolder: "リワード名を入力")
                            }
                        }
                        // description
                        DescriptionTextEditor(description: $vm.rewardDescription, focused: _focused)
                        
                        // point
                        VStack(alignment: .center, spacing: 5) {
                            SectionLabel(text: "コスト", font: .callout.bold(), color: Color(.indigo), width: 3)
                            UnderLineNumField(fieldValue: $fieldNum, num: $vm.cost, field: FormField.number)
                                .validation(vm.costValidation)
                        }
                        
                        WhoGetsPaidPicker(whoGetsPaid: $vm.whoGetsPaid)
                        
                        //setting frequency
//                        FrequencyPicker(label: "くりかえし", frequencyType: $vm.frequencyType)
//                        
//                        VStack(spacing: 10) {
//                            Toggle(isOn: $vm.isLimited) {
//                                HStack {
//                                    SectionLabel(text: "スケジューリング", font: .callout.bold(), color: Color(.indigo), width: 3)
//                                    
//                                    Spacer()}
//                            }
//                            .toggleStyle(SwitchToggleStyle(tint: Color(.indigo)))
//                            .padding(.trailing)
//                            
//                            if vm.isLimited {
//                                PeriodPicker(start: $vm.startDate, end: $vm.endDate)
//                            }
//                        }
                        
                        Spacer()
                        
                        HStack(spacing: 10) {
                            if vm.isEdit {
                                ActionWithFlagFillButton(label: "リワードを削除",
                                                         action: {
                                    isDelete = true
                                    vm.confirmRewardAlertProp.title = "削除しますか？"
                                    vm.confirmRewardAlertProp.text = vm.deleteText
                                    vm.completeRewardAlertProp.title = "削除完了!!"
                                    vm.completeRewardAlertProp.text = vm.completeDelete
                                    vm.confirmRewardAlertProp.action = vm.deleteRewards
                                },
                                                         color: Color.red, flag: $vm.confirmRewardAlertProp.isPresented)
                            }
                            ActionWithFlagFillButton(label: vm.isEdit ? "リワードを編集" : "リワードを作成", action: { vm.confirmRewardAlertProp.action = vm.createReward }, color: Color(vm.isEdit ? .indigo : .jade), flag: $vm.confirmRewardAlertProp.isPresented, condition: vm.formValid.isSuccess == false)
                                .padding(.vertical)
                            
                        }
                    }
                    .padding(.vertical)
                    .padding(.horizontal, 20)
                    .padding(.top)
                    .frame(width: deviceWidth())
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(vm.isEdit ? "リワード編集" : "リワード作成").font(.headline)
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
        .popupActionAlert(prop: $vm.confirmRewardAlertProp, actionLabel: isDelete ? "削除" : vm.isEdit ? "編集" : "作成")
        .popupDismissAndActionAlert(prop: $vm.completeRewardAlertProp, dismissLabel: "戻る", actionLabel: "新規作成")
        .popupAlert(prop: $vm.apiErrorPopAlertProp)
        .loading(isLoading: $vm.isLoading)
    }
}


struct RewardImageSelectSection: View {
    @Binding var showImagePicker: Bool
    let thumbnailKey: String?
    let image: UIImage
    var body: some View {
        Button(action: {
            showImagePicker = true
        })
        {
            if let thumbnail = thumbnailKey {
                Thumbnail(type: ThumbnailType.rewards, url: thumbnail, aspect: 90)
                    .padding(.top)
            } else {
                Thumbnail(type: ThumbnailType.rewards, image: image, aspect: 90)
                    .padding(.top)
            }
        }
    }
}
