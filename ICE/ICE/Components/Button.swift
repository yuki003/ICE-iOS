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
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.indigo), lineWidth: 2))
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
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.jade), lineWidth: 2))
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
            Text("コードを送信")
                .font(.footnote.bold())
                .foregroundStyle(Color(.jade))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.jade), lineWidth: 2))
        .frame(width: commonButtonWidth())
    }
}

struct SignOutButton: View {
    var auth: AmplifyAuthService
    var body: some View {
        Button(action: {
            Task {
                try await auth.signOutLocally()
            }
        })
        {
            Text("ログアウト")
                .font(.footnote.bold())
                .foregroundStyle(Color(.jade))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.jade), lineWidth: 2))
        .frame(width: commonButtonWidth())
    }
}

struct BackButton: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Button(action: {
            withAnimation(.linear) {
                dismiss.callAsFunction()
            }
        })
        {
            Text("戻る")
                .font(.footnote.bold())
                .foregroundStyle(Color(.gray))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.gray), lineWidth: 2))
        .frame(width: commonButtonWidth())
    }
}

struct HostUserButton: View {
    var vm: AuthViewModel
    var body: some View {
        Button(action: {
            withAnimation(.linear) {
                vm.navHostOrGuest = false
                if vm.isSignIn {
                    vm.navSignIn = true
                } else if vm.isSignUp {
                    vm.navSignUp = true
                }
            }
        })
        {
            Text("ホストユーザー")
                .font(.footnote.bold())
                .foregroundStyle(Color(.indigo))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.indigo), lineWidth: 2))
        .frame(width: commonButtonWidth())
    }
}

struct GuestUserButton: View {
    var vm: AuthViewModel
    var body: some View {
        Button(action: {
            withAnimation(.linear) {
                vm.navHostOrGuest = false
                vm.asGuest = true
                if vm.isSignIn {
                    vm.navSignIn = true
                } else if vm.isSignUp {
                    vm.navSignUp = true
                }
            }
        })
        {
            Text("招待を受けている方(ゲスト)")
                .font(.footnote.bold())
                .foregroundStyle(Color(.jade))
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 4).stroke(Color(.jade), lineWidth: 2))
        .frame(width: commonButtonWidth())
    }
}

struct XMarkButton: View {
    @Binding var flag: Bool
    let width: CGFloat
    let height: CGFloat
    let color: Color
    var body: some View {
        Button(action: {
            withAnimation(.linear) {
                flag.toggle()
            }
        })
        {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: width, height: height)
                .font(.callout.bold())
                .foregroundStyle(color)
        }
    }
}

struct AddButton: View {
    @Binding var flag: Bool
    var body: some View {
        Button(action: {
            flag = true
        })
        {
            AddSquareIcon()
        }
    }
}
