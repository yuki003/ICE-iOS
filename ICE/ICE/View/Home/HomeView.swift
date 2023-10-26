//
//  HomeView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/19.
//

import SwiftUI

struct HomeView: View {
//    @StateObject var vm: HomeViewModel
    @ObservedObject var auth = AmplifyAuthService()
    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            SignOutButton(auth: auth)
        }
    }
}
