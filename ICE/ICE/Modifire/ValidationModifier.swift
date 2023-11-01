//
//  ValidationModifier.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/21.
//

import Foundation
import Combine
import SwiftUI

struct ValidationModifier: ViewModifier {
    @State var validation: Validation = .success
    
    let publisher: AnyPublisher<Validation, Never>
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading) {
            content
            if !validation.isSuccess {
                message
            }
        }
        .onReceive(publisher) { validation in
            withAnimation(.linear) {
                self.validation = validation
            }
        }
    }
    
    var message: some View {
        switch validation {
        case .success:
            return AnyView(EmptyView())
        case let .failed(message):
            let view =
            VStack {
                if let message = message {
                    Text(message)
                        .foregroundStyle(Color(.indigo))
                        .font(.footnote.bold())
                } else {
                    EmptyView()
                }
            }
            return AnyView(view)
        }
    }
}
