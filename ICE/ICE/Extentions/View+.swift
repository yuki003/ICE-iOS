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
        return UIScreen.main.bounds.width / 1.2
    }
    
    func sectionWidth() -> CGFloat{
        return UIScreen.main.bounds.width / 1.3
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
    
    func userToolbar(state: LoadingState, userName: String) -> some View {
        modifier(UserToolbarModifier(state: state, userName: userName))
    }
    
    func dismissButton() -> some View {
        self.modifier(DismissButtonModifier())
    }
    
    func validation(_ publisher: AnyPublisher<Validation, Never>) -> some View {
        modifier(ValidationModifier(publisher: publisher))
    }
    
    func loading(isLoading: Binding<Bool>) -> some View {
        modifier(LoadingModifier(isLoading: isLoading))
    }
    
    func roundedSection(color: Color) -> some View {
        modifier(RoundedSectionModifier(color: color))
    }
}