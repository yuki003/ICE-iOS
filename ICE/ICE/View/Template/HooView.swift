//
//  HooView.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/31.
//

import SwiftUI

//最初のView
struct HooView: View {
    @State private var activie = false
    @State private var backgroundColor = UIColor.white
    var body: some View {
        NavigationStack{
            ZStack{
                Color(backgroundColor)
                    .ignoresSafeArea()
                VStack{
                    Text("FIrstPage")
                    Button {
                        activie.toggle()
                        backgroundColor = .cyan
                    } label: {
                        HStack{
                            Image(systemName: "arrowshape.right.fill")
                            Text("NextPage")
                        }
                }

            }
            }.buttonStyle(.bordered)
                .navigationDestination(isPresented: $activie, destination: {
                    nextView()
                })
        }
        .frame(width: screenWidth())
        .roundedBorder(color: Color(.indigo))
    }
}
//遷移先のView
struct nextView: View {
    var body: some View {
        NavigationView {
            ZStack{
                Color.black
                    .ignoresSafeArea()
                Text("SecondView")
                    .foregroundColor(.white)
            }
        }
    }
}
