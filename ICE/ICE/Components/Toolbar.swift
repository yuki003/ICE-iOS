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
            }
        }
    }
}

struct UserToolbar: ToolbarContent {
    var state: LoadingState
    var userName: String
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if state == .loaded {
                HStack(alignment: .center, spacing: 10) {
                    DefaultUserThumbnail()
                        .frame(width: 30, height: 30)
                    Text("\(userName)")
                        .font(.system(size: 15, weight: .heavy))
                        .frame(maxWidth: 200)
                        .foregroundStyle(Color.black)
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
