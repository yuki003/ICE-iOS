//
//  SignUpView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: SignUpViewModel
    @FocusState private var focused: AuthField?
    var body: some View {
        VStack(spacing: 20) {
            EmailTextField(email: $vm.email, focused: _focused)
            
            PasswordTextField(password: $vm.password, focused: _focused)
            
            LoginAsGuestButton(asGuest: $vm.asGuest)
            
            BackButton(dismiss: _dismiss)
        }
//        .dismissButton()
        .padding()
    }
}

#Preview {
    SignInView(vm: .init())
}
