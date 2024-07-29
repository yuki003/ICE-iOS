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
        return UIScreen.main.bounds.width - 96
    }
    
    func commonButtonWidth() -> CGFloat{
        return UIScreen.main.bounds.width / 1.7
    }
    
    func dismissToolbar<Content: ToolbarContent>(@ToolbarContentBuilder content: @escaping () -> Content) -> some View {
        modifier(DismissToolbarModifier(toolbar: content))
    }
    
    func userToolbar(userName: String?, dismissExists: Bool = false) -> some View {
        modifier(UserToolbarModifier(userName: userName, dismissExists: dismissExists))
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
    
    func popupActionAlert(prop: Binding<PopupAlertProperties>, actionLabel: String = "実行") -> some View {
        modifier(PopupActionAlertModifier(prop: prop, actionLabel: actionLabel))
    }
    
    func popupDismissAlert(prop: Binding<PopupAlertProperties>, buttonLabel: String = "戻る") -> some View {
        modifier(PopupDismissAlertModifier(prop: prop, buttonLabel: buttonLabel))
    }
    
    func popupDismissAndActionAlert(prop: Binding<PopupAlertProperties>, dismissLabel: String = "戻る", actionLabel: String = "実行") -> some View {
        modifier(PopupDismissAndActionAlertModifier(prop: prop, dismissLabel: dismissLabel, actionLabel: actionLabel))
    }
    
    func popupAlert(prop: Binding<PopupAlertProperties>, dismissLabel: String = "閉じる") -> some View {
        modifier(PopupAlertModifier(prop:prop, buttonLabel: dismissLabel))
    }
    
    func popupTaskIconSelector(isPresented: Binding<Bool>, taskType: Binding<TaskType>, color: Color = Color(.indigo), buttonLabel: String = "決定") -> some View {
        modifier(PopupTaskIconModifier(isPresented: isPresented, taskType: taskType, color: color, buttonLabel: buttonLabel))
    }
    
    func popupImage(isPresented: Binding<Bool>, url: String) -> some View {
        modifier(PopupImageModifier(isPresented: isPresented, url: url))
    }
    
    func alertStacked(isPresented: Binding<Bool>, content: () -> Alert) -> some View {
        overlay(
            EmptyView().alert(isPresented: isPresented, content: content),
            alignment: .bottomTrailing
        )
    }
}

