//
//  RewardApprovalView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2024/10/21.
//

import SwiftUI
import Amplify

struct RewardApprovalView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: RewardApprovalViewModel
    @StateObject var rewardService: RewardService
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 20) {
                    VStack(alignment: .center, spacing: 5) {
                        // rewardName
                        HStack(alignment: .bottom, spacing: 10) {
                            SectionLabel(text: "リワード名", font: .callout.bold(), color: Color(.indigo), width: 3)
                            Text(vm.reward.rewardName)
                                .font(.callout.bold())
                                .foregroundStyle(Color.black)
                            Spacer()
                        }
                    }
                    // description
                    if let description = vm.reward.description, !description.isEmpty {
                        HStack(alignment: .bottom, spacing: 10) {
                            SectionLabel(text: "概要", font: .callout.bold(), color: Color(.indigo), width: 3)
                            Text(description)
                                .font(.caption.bold())
                                .foregroundStyle(Color.black)
                            Spacer()
                        }
                    }
                    
                    // point
                    HStack(alignment: .bottom, spacing: 10) {
                        SectionLabel(text: "コスト", font: .callout.bold(), color: Color(.indigo), width: 3)
                        Text("\(vm.reward.cost)")
                            .font(.callout.bold())
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                    
                    HStack(alignment: .bottom, spacing: 10) {
                        SectionLabel(text: "制約", font: .callout.bold(), color: Color(.indigo), width: 3)
                        Text("\(EnumUtility().translateWhoGetsPaid(who: vm.reward.whoGetsPaid))")
                            .font(.caption.bold())
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                    
                    //setting frequency
                    HStack(alignment: .bottom, spacing: 10) {
                        SectionLabel(text: "頻度", font: .callout.bold(), color: Color(.indigo), width: 3)
                        Text("\(EnumUtility().translateFrequencyType(frequency: vm.reward.frequencyType))")
                            .font(.caption.bold())
                            .foregroundStyle(Color.black)
                        Spacer()
                    }
                    
                    if let startDate = vm.reward.startDate {
                        HStack(alignment: .bottom, spacing: 10) {
                            SectionLabel(text: "開始日", font: .callout.bold(), color: Color(.indigo), width: 3)
                            Text(startDate.foundationDate.toFormat("yyyy/MM/dd"))
                                .font(.caption.bold())
                                .foregroundStyle(Color.black)
                            Spacer()
                        }
                    }
                    
                    
                    if let endDate = vm.reward.endDate {
                        HStack(alignment: .bottom, spacing: 10) {
                            SectionLabel(text: "終了日", font: .callout.bold(), color: Color(.indigo), width: 3)
                            Text(endDate.foundationDate.toFormat("yyyy/MM/dd"))
                                .font(.caption.bold())
                                .foregroundStyle(Color.black)
                            Spacer()
                        }
                    }
                    
                    if !vm.appliedUserList.isEmpty {
                        SectionLabel(text: "申請中のユーザー", font: .callout.bold(), color: Color(.indigo), width: 3)
                        
                        ForEach(vm.appliedUserList.indices, id:\.self) { index in
                            let user = vm.appliedUserList[index]
                            UserRow(user: user, selectedUserID: $vm.selectedUserID, forwardAction: vm.approveRewardAction, rejectAction: vm.rejectRewardAction)
                                .onTapGesture {
                                    vm.selectedUserID = user.userID
                                }
                        }
                    }
                }
                .padding(.vertical)
                .padding(.horizontal, 20)
                .padding(.top)
                .frame(width: deviceWidth())
            }
        }
        .task {
            await vm.loadData()
        }
        .popupActionAlert(prop: $vm.approveConfirmAlertProp)
        .popupActionAlert(prop: $vm.rejectConfirmAlertProp)
        .popupDismissAlert(prop: $vm.approvedAlertProp)
        .popupDismissAlert(prop: $vm.rejectedAlertProp)
        .loading(isLoading: $rewardService.isLoading)
        .dismissToolbar {
            ToolbarItem(placement: .principal) {
                HStack(alignment: .center, spacing: 10) {
                    RewardImageSection(thumbnailKey: vm.reward.thumbnailKey, image: vm.image)
                    Text(vm.reward.rewardName)
                        .font(.callout.bold())
                        .foregroundStyle(Color.black)
                    Spacer()
                    Text("\(vm.reward.cost.comma())pt")
                        .font(.callout.bold())
                        .foregroundStyle(Color(.indigo))
                        .padding(.trailing, 10)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .loading(isLoading: $vm.isLoading)
    }
}


struct RewardImageSection: View {
    let thumbnailKey: String?
    let image: UIImage
    var body: some View {
        if let thumbnail = thumbnailKey, thumbnail.isNotEmpty {
            Thumbnail(type: ThumbnailType.rewards, url: thumbnail, aspect: 30)
                .padding(.top)
        } else {
            Thumbnail(type: ThumbnailType.rewards, image: image, aspect: 30)
                .padding(.top)
        }
    }
}
