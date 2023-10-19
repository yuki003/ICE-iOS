//
//  Button.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import SwiftUI
import Amplify

struct ClearButton: View {
    @Binding var text: String
    
    var body: some View {
        Button(action: {
            text = ""
        })
        {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(Color(.jade))
                .font(.system(size: 12))
        }
    }
}

struct VisibilityToggleButton: View {
    @Binding var isSecured: Bool
    
    var body: some View {
        Button(action: {
            isSecured.toggle()
        }) {
            Image(systemName: isSecured ? "eye.slash" : "eye")
                .foregroundColor(.gray)
                .font(.system(size: 12))
        }
    }
}

struct LoginAsGuestButton: View {
    @Binding var asGuest: Bool
    var body: some View {
        Button(action: {
            asGuest = true
        })
        {
            Text("ゲストユーザーとして登録")
                .font(.footnote.bold())
                .foregroundStyle(Color.black)
        }
    }
}

struct SignInButton: View {
    var vm: AuthViewModel
    var body: some View {
        Button(action: {
            Task {
                try await vm.signIn()
            }
        })
        {
            Text("ログイン")
                .font(.footnote.bold())
                .foregroundStyle(Color(.indigo))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.indigo)))
        .frame(width: commonButtonWidth())
    }
}

struct SignUpButton: View {
    var vm: AuthViewModel
    var body: some View {
        Button(action: {
            Task {
                try await vm.signUp()
            }
        })
        {
            Text("新規登録")
                .font(.footnote.bold())
                .foregroundStyle(Color(.jade))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.jade)))
        .frame(width: commonButtonWidth())
    }
}

struct ConfirmSignUpButton: View {
    var vm: AuthViewModel
    var body: some View {
        Button(action: {
            Task {
                try await vm.signUpConfirmation()
            }
        })
        {
            Text("新規登録")
                .font(.footnote.bold())
                .foregroundStyle(Color(.jade))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.jade)))
        .frame(width: commonButtonWidth())
    }
}

struct BackButton: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button(action: {
            dismiss.callAsFunction()
        })
        {
            Text("戻る")
                .font(.footnote.bold())
                .foregroundStyle(Color(.gray))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.gray)))
        .frame(width: commonButtonWidth())
    }
}
