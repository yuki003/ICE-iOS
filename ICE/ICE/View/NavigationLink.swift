//
//  NavigationLink.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/26.
//

import SwiftUI

struct HomeNavigation: View {
    @Binding var nav: Bool
    var body: some View {
        NavigationLink(
            destination: HomeView(vm: .init()),
            isActive: $nav,
            label: EmptyView.init
        )
    }
}
