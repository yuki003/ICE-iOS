//
//  Toolbar.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/16.
//

import SwiftUI

struct DismissToolbar: ToolbarContent {
    var dismiss: DismissAction
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: {
                self.dismiss.callAsFunction()
            }) {
                Image(systemName: "chevron.left")
                    .font(.callout)
                    .foregroundStyle(Color(.indigo))
            }
        }
    }
}

struct UserToolbar: ToolbarContent {
    var state: LoadingState
    var userName: String?
    @Environment(\.dismiss) var dismiss
    var dismissExists: Bool
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            Spacer()
            Button(action: {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
            {
                Text("閉じる")
                    .foregroundStyle(Color(.indigo))
                    .bold()
                    .padding(.trailing)
            }
        }
        ToolbarItem(placement: .navigationBarLeading) {
            if state == .loaded {
                HStack(alignment: .center, spacing: 5) {
                    if dismissExists {
                        Button(action: {
                            self.dismiss.callAsFunction()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.callout)
                                .foregroundStyle(Color(.indigo))
                        }
                    }
                    Thumbnail(type: ThumbnailType.user, aspect: 30)
                    if let name = userName {
                        Text("\(name)")
                            .font(.system(size: 15, weight: .heavy))
                            .frame(maxWidth: 200)
                            .foregroundStyle(Color.black)
                    }
                }
                .padding(.leading, 5)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
                print("Push SettingButton")
            })
            {
                SettingIcon()
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(Color.black)
                    .padding(.trailing, 5)
                
            }
        }

    }
}
