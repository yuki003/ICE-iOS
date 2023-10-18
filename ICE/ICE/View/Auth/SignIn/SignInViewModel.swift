//
//  SignInViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import Foundation

final class SignInViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
}
