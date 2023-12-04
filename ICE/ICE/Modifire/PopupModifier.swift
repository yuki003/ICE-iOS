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

struct PopupDismissAndActionAlertModifier: ViewModifier {
    @Binding var isPresented: Bool
    var title: String?
    let text: String
    var dismissLabel: String
    var actionLabel: String
    let action: () async throws -> Void
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
                            DismissRoundedButton(label: dismissLabel, color: Color(.indigo))
                            ActionFillButton(label: actionLabel, action: action, color: Color(.jade))
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

struct PopupTaskIconModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var taskType: TaskType
    @State var select: TaskType = .defaultIcon
    var color: Color
    var buttonLabel: String
    let layout = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    @State var selected: Bool = false
    @State private var selectedStates: [Bool] = Array(repeating: false, count: TaskType.allCases.count)
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    GrayBackgroundView()
                    
                    VStack(spacing: 15) {
                        ScrollView {
                            // グリッドレイアウトを使用
                            LazyVGrid(columns: layout, spacing: 20) {
                                //                        HStack (alignment: .center, spacing: 10) {
                                ForEach(TaskType.allCases.indices, id: \.self) { index in
                                    Button(action: {
                                        selectedStates = Array(repeating: false, count: TaskType.allCases.count)
                                        selectedStates[index].toggle()
                                        select = TaskType.allCases[index]
                                    })
                                    {
                                        TaskIcon(thumbnail: TaskType.allCases[index].icon, defaultColor: Color.gray, aspect: 50, selected: selectedStates[index])
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                        }
                        //                        }
                        ActionFillButton(label: buttonLabel, action: {
                            selected = false
                            taskType = select
                            isPresented = false
                        }, color: color)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.2, maxHeight: 300)
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
