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
    @Binding var frequencyAndPeriodic: FrequencyAndPeriodic
    var translatedFrequency: String {
        enumUtil.translateFrequencyType(frequency: frequencyAndPeriodic.frequency)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SectionLabel(text: "発生頻度", font: .callout.bold(), color: Color(.indigo), width: 3)
            Menu {
                ForEach(FrequencyType.allCases, id: \.self) { type in
                    Button(enumUtil.translateFrequencyType(frequency: type), action: {
                        frequencyAndPeriodic.frequency = type
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

struct PeriodicPicker: View {
    @ObservedObject var enumUtil = EnumUtility()
    @Binding var frequencyAndPeriodic: FrequencyAndPeriodic
    var translatedPeriodic: String? {
        enumUtil.translatePeriodicType(periodic: frequencyAndPeriodic.periodic)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            SectionLabel(text: "タイミング", font: .callout.bold(), color: Color(.indigo), width: 3)
            Menu {
                ForEach(PeriodicType.allCases, id: \.self) { type in
                    Button(enumUtil.translatePeriodicType(periodic: type)!, action: {
                        frequencyAndPeriodic.periodic = type
                    })
                }
            } label: {
                HStack(alignment: .center, spacing: 20) {
                    Text(translatedPeriodic ?? "選択してください")
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

struct FrequencyAndPeriodic {
    var frequency: FrequencyType = .onlyOnce
    var periodic: PeriodicType?
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
