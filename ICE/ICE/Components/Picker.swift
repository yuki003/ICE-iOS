//
//  Picker.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/11/08.
//

import Foundation
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    // MARK: - Working with UIViewControllerRepresentable
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator  // Coordinater to adopt UIImagePickerControllerDelegate Protcol.
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }

    // MARK: - Using Coordinator to Adopt the UIImagePickerControllerDelegate Protocol
    @Binding var selectedImage: UIImage
    @Environment(\.presentationMode) private var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
     
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                parent.selectedImage = image
            }
     
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}


struct FrequencyPicker: View {
    @ObservedObject var enumUtil = EnumUtility()
    let label: String
    @Binding var frequencyType: FrequencyType
    var translatedFrequency: String {
        enumUtil.translateFrequencyType(frequency: frequencyType)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SectionLabel(text: label, font: .callout.bold(), color: Color(.indigo), width: 3)
            Menu {
                ForEach(FrequencyType.allCases, id: \.self) { type in
                    Button(enumUtil.translateFrequencyType(frequency: type), action: {
                        frequencyType = type
                    })
                }
            } label: {
                HStack(alignment: .center, spacing: 20) {
                    Text(translatedFrequency)
                        .font(.callout.bold())
                        .foregroundStyle(Color.black)
                    ArrowTriangleIcon(direction: Direction.down)
                        .frame(width: 10, height: 10)
                        .foregroundStyle(Color.black)
                    Spacer()
                }
                .padding(.vertical)
                .padding(.leading)
                .frame(width: textFieldWidth(), height: 30)
            }
        }
    }
}

struct WhoGetsPaidPicker: View {
    @ObservedObject var enumUtil = EnumUtility()
    @Binding var whoGetsPaid: WhoGetsPaid
    var translatedWhoGetsPaid: String? {
        enumUtil.translateWhoGetsPaid(who: whoGetsPaid)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SectionLabel(text: "獲得できる人", font: .callout.bold(), color: Color(.indigo), width: 3)
            Menu {
                ForEach(WhoGetsPaid.allCases, id: \.self) { who in
                    Button(enumUtil.translateWhoGetsPaid(who: who), action: {
                        whoGetsPaid = who
                    })
                }
            } label: {
                HStack(alignment: .center, spacing: 20) {
                    Text(translatedWhoGetsPaid ?? "選択してください")
                        .font(.callout.bold())
                        .foregroundStyle(Color.black)
                    ArrowTriangleIcon(direction: Direction.down)
                        .frame(width: 10, height: 10)
                        .foregroundStyle(Color.black)
                    Spacer()
                }
                .padding(.vertical)
                .padding(.leading)
                .frame(width: textFieldWidth(), height: 30)
            }
        }
    }
}

struct PeriodPicker: View {
    @Binding var start: Date
    @Binding var end: Date
    @State var showPicker: Bool = false
    @State var editStartDate: Bool = false
    @ViewBuilder
    private func dateLabel(_ date: Date) -> some View {
        HStack {
            Text("\(date.toFormat("yyyy/MM/dd"))")
            Image(systemName: "calendar")
        }
        .foregroundStyle(Color.black)
    }
    var body: some View {
        if showPicker {
            VStack(alignment: .center, spacing: 10) {
                Text(editStartDate ? "スタート" : "エンド")
                    .font(.callout.bold())
                CustomDatePicker(
                    showDatePicker: $showPicker,
                    start: $start,
                    savedDate: editStartDate ? $start : $end,
                    selectedDate: editStartDate ? start : end,
                    editStartDate: $editStartDate
                )
                .animation(.linear, value: start)
                .transition(.opacity)
            }
        } else {
            HStack(spacing: 5) {
                VStack(alignment: .center, spacing: 10) {
                    Text("スタート")
                        .font(.body.bold())
                    Button {
                        withAnimation(.easeOut(duration: 0.3)) {
                            editStartDate = true
                            showPicker.toggle()
                        }
                    } label: {
                        VStack(spacing: 2) {
                            dateLabel(start)
                            Rectangle()
                                .foregroundStyle(Color(.indigo))
                                .frame(width: 140, height: 2)
                        }
                    }
                    .background()
                }
                .frame(width: (screenWidth() - 30) / 2)
                Text("to")
                    .font(.body.bold())
                VStack(alignment: .center, spacing: 10) {
                    Text("エンド")
                        .font(.body.bold())
                    Button {
                        withAnimation(.easeOut(duration: 0.3)) {
                            editStartDate = false
                            showPicker.toggle()
                        }
                    } label: {
                        VStack(spacing: 2) {
                            dateLabel(end)
                            Rectangle()
                                .foregroundStyle(Color(.indigo))
                                .frame(width: 140, height: 2)
                        }
                    }
                    .background()
                }
                .frame(width: (screenWidth() - 30) / 2)
            }
            .frame(width: screenWidth())
        }
    }
}

struct CustomDatePicker: View {
    @Binding var showDatePicker: Bool
    @Binding var start: Date
    @Binding var savedDate: Date
    @State var selectedDate: Date = Date()
    @Binding var editStartDate: Bool
    var dayAfterStart: Date {
        if !editStartDate {
            return Calendar.current.date(byAdding: .day, value: 1, to: start)!
        } else {
            return Date()
        }
    }
    
    var body: some View {
        VStack {
            if editStartDate {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            } else {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: dayAfterStart...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }
            Divider()
            HStack {
                Button("キャンセル") {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showDatePicker = false
                    }
                }
                Spacer()
                Button("決定") {
                    withAnimation(.easeOut(duration: 0.3)) {
                        savedDate = selectedDate
                        showDatePicker = false
                    }
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 10)
        }
        .padding(.horizontal, 20)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(.indigo), lineWidth: 2))
    }
}
