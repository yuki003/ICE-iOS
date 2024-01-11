//
//  View+.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/15.
//

import SwiftUI
import Combine

extension View {
    func deviceWidth() -> CGFloat{
        return UIScreen.main.bounds.width
    }
    
    func screenWidth() -> CGFloat{
        return UIScreen.main.bounds.width - 32
    }
    
    func cardWidth() -> CGFloat{
        return UIScreen.main.bounds.width / 2.3
    }
    
    func textFieldWidth() -> CGFloat{
        return UIScreen.main.bounds.width / 1.5
    }
    
    func commonButtonWidth() -> CGFloat{
        return UIScreen.main.bounds.width / 1.7
    }
    
    func dismissToolbar<Content: ToolbarContent>(@ToolbarContentBuilder content: @escaping () -> Content) -> some View {
        modifier(DismissToolbarModifier(toolbar: content))
    }
    
    func userToolbar(state: LoadingState, userName: String?, dismissExists: Bool = false) -> some View {
        modifier(UserToolbarModifier(state: state, userName: userName, dismissExists: dismissExists))
    }
    
    func dismissButton() -> some View {
        self.modifier(DismissButtonModifier())
    }
    
    func validation(_ publisher: AnyPublisher<Validation, Never>, alignmentCenter: Bool = false) -> some View {
        modifier(ValidationModifier(publisher: publisher, alignmentCenter: alignmentCenter ))
    }
    
    func loading(isLoading: Binding<Bool>) -> some View {
        modifier(LoadingModifier(isLoading: isLoading))
    }
    
    func roundedSection(color: Color) -> some View {
        modifier(RoundedSectionModifier(color: color))
    }
    
    func popupActionAlert(isPresented: Binding<Bool>, title: String? = nil, text: String, action: @escaping () async throws -> Void, actionLabel: String = "実行", color: Color = Color(.indigo)) -> some View {
        modifier(PopupActionAlertModifier(isPresented: isPresented, title: title, text: text, action: action, actionLabel: actionLabel, color: color))
    }
    
    func popupDismissAlert(isPresented: Binding<Bool>, title: String? = nil, text: String, color: Color = Color(.indigo), buttonLabel: String = "戻る") -> some View {
        modifier(PopupDismissAlertModifier(isPresented: isPresented, title: title, text: text, color: color, buttonLabel: buttonLabel))
    }
    
    func popupDismissAndActionAlert(isPresented: Binding<Bool>, title: String? = nil, text: String, dismissLabel: String = "戻る", actionLabel: String = "実行", action: @escaping () async throws -> Void) -> some View {
        modifier(PopupDismissAndActionAlertModifier(isPresented: isPresented, title: title, text: text, dismissLabel: dismissLabel, actionLabel: actionLabel, action: action))
    }
    
    func popupTaskIconSelector(isPresented: Binding<Bool>, taskType: Binding<TaskType>, color: Color = Color(.indigo), buttonLabel: String = "決定") -> some View {
        modifier(PopupTaskIconModifier(isPresented: isPresented, taskType: taskType, color: color, buttonLabel: buttonLabel))
    }
}

