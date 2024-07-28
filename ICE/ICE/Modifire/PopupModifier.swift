//
//  Popup.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/13.
//

import SwiftUI
import Kingfisher

struct PopupActionAlertModifier: ViewModifier {
    @Binding var prop: PopupAlertProperties
    let action: () async throws -> Void
    var actionLabel: String
    func body(content: Content) -> some View {
        content
            .overlay {
                if prop.isPresented {
                    GrayBackgroundView()
                        .ignoresSafeArea()

                    VStack(spacing: 15) {
                        if prop.title.isNotEmpty {
                            Text(prop.title)
                                .foregroundColor(Color.black)
                                .font(.callout.bold())
                                .padding(.top)
                        }

                        Text(prop.text)
                            .foregroundColor(Color.black)
                            .font(.footnote.bold())
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 15)

                        HStack (alignment: .center, spacing: 10) {
                            FlagFillButton(label: "キャンセル", color: Color.red, flag: $prop.isPresented)
                            ActionWithFlagFillButton(label: actionLabel, action: action, color: prop.color, flag: $prop.isPresented)
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
    @Binding var prop: PopupAlertProperties
    var buttonLabel: String
    func body(content: Content) -> some View {
        content
            .overlay {
                if prop.isPresented {
                    GrayBackgroundView()

                    VStack(spacing: 15) {
                        if prop.title.isNotEmpty {
                            Text(prop.title)
                                .foregroundColor(Color.black)
                                .font(.callout.bold())
                                .padding(.top)
                        }

                        Text(prop.text)
                            .foregroundColor(Color.black)
                            .font(.footnote.bold())
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 15)

                        HStack (alignment: .center, spacing: 10) {
                            DismissRoundedButton(label: buttonLabel, color: prop.color)
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
    @Binding var prop: PopupAlertProperties
    var dismissLabel: String
    var actionLabel: String
    let action: () async throws -> Void
    func body(content: Content) -> some View {
        content
            .overlay {
                if prop.isPresented {
                    GrayBackgroundView()

                    VStack(spacing: 15) {
                        if prop.title.isNotEmpty {
                            Text(prop.title)
                                .foregroundColor(Color.black)
                                .font(.callout.bold())
                                .padding(.top)
                        }

                        Text(prop.text)
                            .foregroundColor(Color.black)
                            .font(.footnote.bold())
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 15)

                        HStack (alignment: .center, spacing: 10) {
                            DismissRoundedButton(label: dismissLabel, color: Color(.indigo))
                            ActionWithFlagFillButton(label: actionLabel, action: action, color: Color(.jade), flag: $prop.isPresented)
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

struct PopupAlertModifier: ViewModifier {
    @Binding var prop: PopupAlertProperties
    var buttonLabel: String
    let action: () async throws -> Void
    func body(content: Content) -> some View {
        content
            .overlay {
                if prop.isPresented {
                    GrayBackgroundView()

                    VStack(spacing: 15) {
                        if prop.title.isNotEmpty {
                            Text(prop.title)
                                .foregroundColor(Color.black)
                                .font(.callout.bold())
                                .padding(.top)
                        }

                        Text(prop.text)
                            .foregroundColor(Color.black)
                            .font(.footnote.bold())
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 15)

                        HStack (alignment: .center, spacing: 10) {
                            ActionWithFlagFillButton(label: buttonLabel, action: action, color: prop.color, flag: $prop.isPresented)
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
                        ActionWithFlagFillButton(label: buttonLabel, action: {
                            selected = false
                            taskType = select
                            select = .defaultIcon
                        }, color: color, flag: $isPresented)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.2, maxHeight: 300)
                    .padding()
                    .background()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
    }
}

struct PopupImageModifier: ViewModifier {
    @Binding var isPresented: Bool
    let url: String
    func body(content: Content) -> some View {
        content
            .overlay {
                if isPresented {
                    GrayBackgroundView()

                    VStack(spacing: 15) {
                        KFImage(URL(string: url))
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width - 32, height: UIScreen.main.bounds.width - 32)
                            .background(Color.clear)
                            .scaledToFit()
                        FlagFillButton(label: "閉じる", color: Color(.indigo), flag: $isPresented)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width / 1.2)
                }
            }
    }
}
struct PopupAlertProperties {
    var isPresented = false
    var title: String = ""
    var text: String = ""
    var color: Color = Color(.indigo)
}
struct GrayBackgroundView: View {
    var body: some View {
        Rectangle()
            .fill(Color(.black).opacity(0.8))
            .ignoresSafeArea()
    }
}
