//
//  Loading.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/25.
//

import SwiftUI

struct LoadingView: View {
    @State var isLoading: Bool = false
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundStyle(Color.white.opacity(0.8))
                .ignoresSafeArea(.all)
            
            Image(.transparentLogo)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(isLoading ? 0 : 360))
                .animation(.linear(duration: 4.0).repeatForever(autoreverses: false), value: isLoading)
                .onAppear {
                    isLoading = true
                }
        }
    }
}


#Preview {
    LoadingView()
}
