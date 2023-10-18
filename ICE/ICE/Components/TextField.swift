//
//  TextField.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import SwiftUI

struct UsernameTextField: View {
    @Binding var userName: String
    @FocusState var focused: AuthField?
    var isFocused: Bool {
        return focused == .username
    }
    
    var body: some View {
        HStack(alignment: .center) {
            TextField("Username", text: $userName)
                .font(.footnote.bold())
            .focused($focused, equals: .username)
            .keyboardType(.default)
            
            ClearButton(text: $userName)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(isFocused ? Color(.indigo) : Color.gray))
        .frame(width: textFieldWidth())
    }
}

struct EmailTextField: View {
    @Binding var email: String
    @FocusState var focused: AuthField?
    var isFocused: Bool {
        return focused == .email
    }
    
    var body: some View {
        HStack(alignment: .center) {
            TextField("Email", text: $email)
                .font(.footnote.bold())
                .focused($focused, equals: .email)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            ClearButton(text: $email)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(isFocused ? Color(.indigo) : Color.gray))
        .frame(width: textFieldWidth())
    }
}


struct PasswordTextField: View {
    @Binding var password: String
    @FocusState var focused: AuthField?
    @State private var isSecured: Bool = true
    var isFocused: Bool {
        return focused == .password
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if isSecured {
                SecureField("Password", text: $password)
                    .font(.footnote.bold())
                    .focused($focused, equals: .password)
                    .keyboardType(.alphabet)
            } else {
                TextField("Password", text: $password)
                    .font(.footnote.bold())
                    .focused($focused, equals: .password)
                    .keyboardType(.alphabet)
            }
            
            HStack(spacing: 5) {
                VisibilityToggleButton(isSecured: $isSecured)
                ClearButton(text: $password)
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(isFocused ? Color(.indigo) : Color.gray))
        .frame(width: textFieldWidth())
    }
}
