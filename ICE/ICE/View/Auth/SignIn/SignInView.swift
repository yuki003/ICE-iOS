//
//  SignInView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: SignInViewModel
    @FocusState private var focused: AuthField?
    var body: some View {
        VStack(spacing: 20) {
            UsernameTextField(userName: $vm.userName, focused: _focused)
            
            PasswordTextField(password: $vm.password, focused: _focused)
            
            BackButton(dismiss: _dismiss)
            
        }
//        .dismissButton()
        .padding()
    }
}

#Preview {
    SignInView(vm: .init())
}
