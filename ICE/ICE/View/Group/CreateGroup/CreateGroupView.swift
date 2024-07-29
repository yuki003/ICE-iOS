//
//  CreateGroupView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/31.
//

import SwiftUI
import Amplify

struct CreateGroupView: View {
    @FocusState private var focused: FormField?
    @StateObject var vm: CreateGroupViewModel
    @EnvironmentObject var router: PageRouter
    @State var createGroupAlertProp: PopupAlertProperties = .init(title: "グループを作成します", text: "現在の内容でグループを作成します。グループ詳細画面から内容を更新することができます。")
    @State var createCompleted: Bool = false
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .center, spacing: 20) {
                    if !createCompleted {
                        groupImageSection()
                            .validation(vm.thumbnailValidation, alignmentCenter: true)
                        UnderLineTextField(text: $vm.groupName, focused: _focused, field: FormField.name, placeHolder: "グループ名を入力")
                            .onChange(of: vm.groupName) { newValue in
                                if newValue.isEmpty {
                                    vm.buttonDisabled = true
                                } else {
                                    vm.buttonDisabled = false
                                }
                            }
                        DescriptionTextEditor(description: $vm.groupDescription, focused: _focused)
                    } else {
                        VStack(alignment: .center, spacing: 20) {
                            Text("グループの登録が完了しました！")
                                .font(.callout.bold())
                            Text("""
                                         ホームからグループの詳細を確認し、
                                         タスクやリワードを設定しましょう!!
                                         """)
                            .font(.footnote.bold())
                        }
                        .padding(.vertical, 20)
                    }
                    CreateGroupCard(groupName: vm.groupName, image: vm.image, description: vm.groupDescription, color: vm.groupName.isEmpty ? Color.gray : Color(.indigo))
                    
                    if createCompleted {
                        DismissRoundedButton(label: "ホームに戻る", color: Color(.indigo))
                    } else {
                        ActionWithFlagFillButton(label: "グループを作成", action: {
                            createGroupAlertProp.action = vm.createGroup
                            createCompleted = true
                        }, color: Color(.jade), flag: $createGroupAlertProp.isPresented, condition: vm.buttonDisabled)
                        .padding(.vertical)
                    }
                    
                }
                .frame(width: deviceWidth())
                .padding(.vertical)
                .onAppear {
                    if vm.groupName.isEmpty {
                        vm.buttonDisabled = true
                    }
                }
                .loading(isLoading: $vm.isLoading)
                .sheet(isPresented: $vm.showImagePicker, content: {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: $vm.image)
                })
            }
            .refreshable {
                Task{
                    await vm.reLoadData()
                }
            }
        }
        .popupActionAlert(prop: $createGroupAlertProp, actionLabel: "作成")
        .popupAlert(prop: $vm.apiErrorPopAlertProp)
        .userToolbar(userName: "ユーザー", dismissExists: true)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onTapGesture {
            self.focused = nil
        }
    }
    
    @ViewBuilder
    func groupImageSection() -> some View {
        Button(action: {
            vm.showImagePicker = true
        })
        {
            Thumbnail(type: ThumbnailType.group, image: vm.image, defaultColor: Color.gray, aspect: 90)
                .padding(.top)
        }
    }
}


//#Preview{
//    HomeView(vm: .init())
//}
