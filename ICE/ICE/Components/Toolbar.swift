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
