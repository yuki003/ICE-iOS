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

struct ConfirmationCodeTextField: View {
    @Binding var code: String
    @FocusState var focused: AuthField?
    var isFocused: Bool {
        return focused == .confirmationCode
    }
    
    var body: some View {
        HStack(alignment: .center) {
            TextField("Code", text: $code)
                .font(.footnote.bold())
                .focused($focused, equals: .confirmationCode)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            ClearButton(text: $code)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(isFocused ? Color(.indigo) : Color.gray))
        .frame(width: textFieldWidth())
    }
}

struct UnderLineTextField: View {
    @Binding var text: String
    @FocusState var focused: FormField?
    let field: FormField
    var placeHolder: String = ""
    var isFocused: Bool {
        return focused == field
    }
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            HStack(alignment: .center) {
                TextField(placeHolder, text: $text)
                    .font(.callout.bold())
                    .focused($focused, equals: field)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                ClearButton(text: $text)
            }
            .padding(8)
            Rectangle()
                .frame(width: textFieldWidth(), height: 2)
                .foregroundStyle(isFocused ? Color(.indigo) : Color.gray)
        }
        .frame(width: textFieldWidth())
    }
}

struct UnderLineNumField: View {
    @Binding var fieldValue: String
    @Binding var num: Int
    @FocusState var focused: FormField?
    let field: FormField
    var isFocused: Bool {
        return focused == field
    }
    
    var body: some View {
        VStack (alignment: .center, spacing: 0) {
            HStack(alignment: .center) {
                TextField("", text: $fieldValue)
                    .onChange(of: fieldValue) { newValue in
                        let filteredValue = String(newValue.filter { "0"..."9" ~= $0 })
                        num = Int(filteredValue) ?? 0
                        
                        fieldValue = num.comma()
                    }
                    .onChange(of: num) { newValue in
                        fieldValue = num.comma()
                    }
                    .font(.callout.bold())
                    .focused($focused, equals: field)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                ClearIntButton(num: $num, text: $fieldValue)
            }
            .padding(8)
            Rectangle()
                .frame(width: textFieldWidth(), height: 2)
                .foregroundStyle(isFocused ? Color(.indigo) : Color.gray)
        }
        .frame(width: textFieldWidth())
    }
}

struct DescriptionTextEditor: View {
    @Binding var description: String
    @FocusState var focused: FormField?
    var isFocused: Bool {
        return focused == .description
    }
    var body: some View {
        VStack(alignment: .leading) {
            TextEditor(text: $description)
                .font(.footnote.bold())
                .focused($focused, equals: .description)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .overlay {
                    if description.isEmpty {
                        Text("説明を入力(任意)")
                            .frame(alignment: .leading)
                            .font(.footnote.bold())
                            .foregroundStyle(Color.gray)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .focused($focused, equals: .description)
                        
                    }
                }
                .background(RoundedRectangle(cornerRadius: 4).stroke(isFocused ? Color(.indigo) : Color.gray))
        }
        .frame(maxWidth: textFieldWidth(), minHeight: 100)
    }
}
