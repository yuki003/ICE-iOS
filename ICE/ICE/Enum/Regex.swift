//
//  Regex.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/21.
//

import Foundation

enum Regex: String {
    case alphanumeric = "^(?=.*[a-zA-Z])(?=.*[0-9]).+$"
    case numbersOnly = "^[0-9]+$"
    case userName = "^[\\p{L}\\p{M}\\p{S}\\p{N}\\p{P}]+$"
    case confirmationCode = "^[0-9]{6}$"
    case email = "[A-Z0-9a-z._+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
}
