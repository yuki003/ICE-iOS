//
//  HomeViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/23.
//

import SwiftUI

final class HomeViewModel: ObservableObject {
    @ObservedObject var auth = AmplifyAuthService()
    
}
