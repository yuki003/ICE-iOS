//
//  ICEApp.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/01.
//

import SwiftUI

@main
struct ICEApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var auth = AmplifyAuthService()
    var body: some Scene {
        WindowGroup {
            VStack {
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
}
