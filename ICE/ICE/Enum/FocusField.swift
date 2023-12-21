//
//  FocusField.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import Foundation

enum AuthField: Hashable {
    case username
    case password
    case email
    case confirmationCode
    case invitedGroupID
}

enum FormField: Hashable {
    // common
    case name
    case description
    // task and reward
    case number
    case itemize
}
