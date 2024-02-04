//
//  Image.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/29.
//

import SwiftUI
import Kingfisher

struct DefaultUserThumbnail: View {
    let color: Color
    var aspect: CGFloat
    var body: some View {
        Image(systemName: "person.fill")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: aspect, height: aspect)
            .foregroundStyle(Color(.indigo))
            .padding(.top, 5)
            .padding(.horizontal, 5)
            .background()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.indigo), lineWidth: 1))
    }
}

struct DefaultGroupThumbnail: View {
    let color: Color
    var aspect: CGFloat

    var body: some View {
        Image(systemName: "figure.2")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: aspect, height: aspect)
            .foregroundStyle(Color(.indigo))
            .padding()
            .background()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.indigo), lineWidth: 2))
    }
}

struct DefaultRewardThumbnail: View {
    let color: Color
    var aspect: CGFloat
    var body: some View {
        Image(.reward)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: aspect, height: aspect)
            .foregroundStyle(Color(.indigo))
            .padding()
            .background()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.indigo), lineWidth: 2))
    }
}

struct DefaultIcon: View {
    let color: Color
    var aspect: CGFloat
    var body: some View {
        IceLogo()
            .frame(width: aspect, height: aspect)
            .aspectRatio(contentMode: .fill)
            .foregroundStyle(Color(.indigo))
            .background()
            .clipShape(Circle())
            .overlay(Circle().stroke(Color(.indigo), lineWidth: 2))
    }
}

struct Thumbnail: View {
    let type: ThumbnailType
    var url: String = ""
    var image: UIImage = UIImage()
    var defaultColor: Color = Color(.indigo)
    var aspect: CGFloat = 40
    var body: some View {
         if image.size != CGSize.zero {
            Image(uiImage: image)
                .resizable()
                .frame(width: aspect, height: aspect)
                .aspectRatio(contentMode: .fill)
                .background()
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.indigo), lineWidth: 2))
        } else if url.isEmpty {
            switch type {
            case .user:
                DefaultUserThumbnail(color: defaultColor, aspect: aspect)
            case .group:
                DefaultGroupThumbnail(color: defaultColor, aspect: aspect)
            case .tasks:
                DefaultIcon(color: defaultColor, aspect: aspect)
            case .rewards:
                DefaultRewardThumbnail(color: defaultColor, aspect: aspect)
            }
        } else {
            KFImage(URL(string: url))
                .resizable()
                .frame(width: aspect, height: aspect)
                .aspectRatio(contentMode: .fill)
                .background()
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(.indigo), lineWidth: 2))
            
        }
    }
}

struct TaskIcon: View {
    let thumbnail: UIImage
    var defaultColor: Color = Color(.indigo)
    var aspect: CGFloat = 40
    var selected: Bool
    var body: some View {
        Image(uiImage: thumbnail)
            .resizable()
            .foregroundStyle(defaultColor)
            .padding(5)
            .frame(width: aspect, height: aspect)
            .aspectRatio(contentMode: .fill)
            .background()
            .clipShape(Circle())
            .overlay(Circle().stroke(selected ? Color(.indigo) : Color.gray, lineWidth: selected ? 2 : 1))
    }
}

struct SettingIcon: View {
    var body: some View {
        Image(systemName: "gearshape")
            .resizable()
    }
}

struct AddSquareIcon: View {
    var body: some View {
        Image(systemName: "plus.square")
            .resizable()
    }
}

struct IceLogo: View {
    var body: some View {
        Image(.logo)
            .resizable()
            .scaledToFill()
    }
}

struct CircleIcon: View {
    var body: some View {
        Image(systemName: "circle.fill")
            .resizable()
    }
}

struct ArrowTriangleIcon: View {
    var direction: Direction
    var systemName: String {
        switch direction {
        case .up:
            "arrowtriangle.up.fill"
        case .down:
            "arrowtriangle.down.fill"
        case .right:
            "arrowtriangle.right.fill"
        case .left:
            "arrowtriangle.left.fill"
        }
    }
    var body: some View {
        Image(systemName: systemName)
            .resizable()
    }
}

struct PaperPlaneIcon: View {
    var body: some View {
        Image(systemName: "paperplane")
            .resizable()
    }
}

struct CameraOnRectangleIcon: View {
    var body: some View {
        Image(systemName: "camera.on.rectangle")
            .resizable()
    }
}

struct XMarkCircleFillIcon: View {
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
    }
}
