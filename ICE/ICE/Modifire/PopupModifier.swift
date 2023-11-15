//
//  Popup.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/13.
//

import SwiftUI

struct PopupActionAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    var title: String?
    let text: String
    let action: () async throws -> Void
    var actionLabel: String
    var color: Color
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    GrayBackgroundView()

                    VStack(spacing: 15) {
                        if let titleText = title {
                            Text(titleText)
                                .foregroundColor(Color.black)
                                .font(.callout.bold())
                                .padding(.top)
                        }

                        Text(text)
                            .foregroundColor(Color.black)
                            .font(.footnote.bold())
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 15)

                        HStack (alignment: .center, spacing: 10) {
                            FlagFillButton(label: "キャンセル", color: Color.red, flag: $isPresented)
                            ActionFillButton(label: actionLabel, action: action, color: color)
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.2)
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
    }
}
struct PopupDismissAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    var title: String?
    let text: String
    var color: Color
    var buttonLabel: String
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    GrayBackgroundView()

                    VStack(spacing: 15) {
                        if let titleText = title {
                            Text(titleText)
                                .foregroundColor(Color.black)
                                .font(.callout.bold())
                                .padding(.top)
                        }

                        Text(text)
                            .foregroundColor(Color.black)
                            .font(.footnote.bold())
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 15)

                        HStack (alignment: .center, spacing: 10) {
                            DismissRoundedButton(label: buttonLabel, color: color)
                        }
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.2)
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
    }
}
struct GrayBackgroundView: View {
    var body: some View {
        Rectangle()
            .fill(Color(.black).opacity(0.5))
            .ignoresSafeArea()
    }
}
