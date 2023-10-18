//
//  AmplifyAuthService.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/16.
//

import Amplify
import Foundation
import SwiftUI
import UIKit

class AmplifyAuthService: ObservableObject {
    @AppStorage("isSignedIn") var isSignedIn = false
    
//    @StateObject var router: AuthRouter = .shared
    
    func checkSessionStatus() async {
        do {
            let result = try await Amplify.Auth.fetchAuthSession()
            if result.isSignedIn {
                self.isSignedIn = true
                print("In Session")
            } else {
                print("Session Expired")
            }
        } catch {
            print(error)
        }
    }
    
    private var window: UIWindow {
        guard
            let scene = UIApplication.shared.connectedScenes.first,
            let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
            let window = windowSceneDelegate.window as? UIWindow
        else { return UIWindow() }
        
        return window
    }

    func webSignIn() async throws {
        do {
//            let options = AuthWebUISignInRequest.Options(scopes: ["ja"])
            let result = try await Amplify.Auth.signInWithWebUI(presentationAnchor: window)
            if result.isSignedIn {
                print("Signed in")
//                router.move(to: .home)
            } else {
                print("Failure")
            }
        } catch {
            print(error)
        }
    }
    func observeAuthEvents() {
        _ = Amplify.Hub.listen(to: .auth) { [weak self] result in
            switch result.eventName {
            case HubPayload.EventName.Auth.signedIn:
                DispatchQueue.main.async {
                    self?.isSignedIn = true
                }
                
            case HubPayload.EventName.Auth.signedOut,
                 HubPayload.EventName.Auth.sessionExpired:
                DispatchQueue.main.async {
                    self?.isSignedIn = false
                }
                
            default:
                break
            }
        }
    }
}
