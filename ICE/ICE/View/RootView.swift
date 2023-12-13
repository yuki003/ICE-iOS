//
//  RootView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/22.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var auth = AmplifyAuthService.shared
    var body: some View {
        ZStack {
            if auth.isSignedIn {
                ContentView()
            } else {
                AuthView(vm: .init())
            }
        }
        .onAppear{
            Task {
                await auth.checkSessionStatus()
                auth.observeAuthEvents()
            }
        }
    }
}
