//
//  ContentView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/01.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var auth = AmplifyAuthService()
    var body: some View {
        VStack {
            HomeView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
