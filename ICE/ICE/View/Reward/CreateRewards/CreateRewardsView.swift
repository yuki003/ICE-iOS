//
//  CreateRewardsView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/12/13.
//

import SwiftUI
import Amplify

struct CreateRewardsView: View {
    @FocusState private var focused: FormField?
    @StateObject var vm: CreateRewardsViewModel
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
                            // thumbnail
                            rewardImageSection()
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
                        FrequencyPicker(label: "くりかえし", frequencyType: $vm.frequencyType)
                        
                        VStack(spacing: 10) {
                            Toggle(isOn: $vm.isLimited) {
                                HStack {
                                    SectionLabel(text: "スケジューリング", font: .callout.bold(), color: Color(.indigo), width: 3)
                                    
                                Spacer()}
                            }
                            .toggleStyle(SwitchToggleStyle(tint: Color(.indigo)))
                            .padding(.trailing)
                            
                            if vm.isLimited {
                                PeriodPicker(start: $vm.startDate, end: $vm.endDate)
                            }
                        }
                        
                        Spacer()
                        if !vm.createComplete {
                            EnabledFlagFillButton(label: "リワードを作成", color: Color(.jade), flag: $vm.showAlert, condition: vm.formValid.isSuccess == false)
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
                    .popupActionAlert(isPresented: $vm.showAlert, title: "作成しますか？",
                                      text:"""
                                           入力した内容でリワードを作成します。
                                           リワードはのちに編集することもできます。
                                           """
                                      , action: { Task { try await vm.createReward()} }, actionLabel: "作成")
                    .popupDismissAndActionAlert(isPresented: $vm.createComplete, title: "作成完了!!", text: "グループ画面から作ったリワードを確認できます。", dismissLabel: "グループ画面に戻る", actionLabel: "このまま続ける", action: { vm.initialization() })
                }
            }
        }
        .loading(isLoading: $vm.isLoading)
        .userToolbar(state: vm.state, userName: nil, dismissExists: true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    func rewardImageSection() -> some View {
        Button(action: {
            vm.showImagePicker = true
        })
        {
            Thumbnail(type: ThumbnailType.rewards, image: vm.image, aspect: 90)
                .padding(.top)
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
