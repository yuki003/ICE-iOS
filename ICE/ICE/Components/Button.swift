//
//  Button.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import SwiftUI

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
    @Binding var navSignIn: Bool
    var body: some View {
        Button(action: {
            withAnimation(.easeIn) {
                navSignIn = true
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
    @Binding var navSignIUp: Bool
    var body: some View {
        Button(action: {
            withAnimation(.easeIn) {
                navSignIUp = true
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
