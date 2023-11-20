//
//  APIService.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/19.
//

import SwiftUI
import Amplify

class APIService: ObservableObject {
    func orPredicateGroupByID(ids: [String?], model: any ModelKey) -> QueryPredicateGroup? {
        var queryPredicateGroup: QueryPredicateGroup = .init(type: .or)
        if !ids.isEmpty {
            for id in ids {
                queryPredicateGroup = queryPredicateGroup.or(model.eq(id))
            }
            return queryPredicateGroup
        } else {
            return nil
        }
    }
}
