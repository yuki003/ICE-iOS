//
//  AuthViewModel.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import Foundation

final class AuthViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var asGuest: Bool = false
    
    @Published var navSignIn: Bool = false
    @Published var navSignUp: Bool = false
    
}
