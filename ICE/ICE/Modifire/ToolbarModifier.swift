//
//  ToolbarModifier.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/16.
//

import SwiftUI

struct DismissToolbarModifier<C: ToolbarContent>: ViewModifier {
    @Environment(\.dismiss) var dismiss
    @ToolbarContentBuilder var toolbar: () -> C
    func body(content: Content) -> some View {
        content
            .toolbar(content: dismissToolbar)
    }
    
    @ToolbarContentBuilder
    func dismissToolbar() -> some ToolbarContent {
        DismissToolbar(dismiss: dismiss)
        toolbar()
    }
}
struct DismissButtonModifier: ViewModifier {
    @Environment(\.dismiss) var dismiss
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar(content: dismissButton)
    }
    
    @ToolbarContentBuilder
    func dismissButton() -> some ToolbarContent {
        DismissToolbar(dismiss: dismiss)
    }
}

struct UserToolbarModifier: ViewModifier {
    var state: LoadingState
    let userName: String?
    var dismissExists: Bool
    func body(content: Content) -> some View {
        content
            .toolbar(content: userInfo)
    }
    
    @ToolbarContentBuilder
    func userInfo() -> some ToolbarContent {
        UserToolbar(state: state, userName: userName, dismissExists: dismissExists)
    }
}
