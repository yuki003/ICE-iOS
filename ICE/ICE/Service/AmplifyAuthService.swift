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
    @AppStorage("userID") var userID: String = ""
    
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
    
    func signUp(username: String, password: String, email: String) async throws -> AuthSignUpResult {
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        do {
            let signUpResult = try await Amplify.Auth.signUp(
                username: username,
                password: password,
                options: options
            )
            if case let .confirmUser(deliveryDetails, _, userId) = signUpResult.nextStep {
                print("Delivery details \(String(describing: deliveryDetails)) for userId: \(String(describing: userId))")
                return signUpResult
            } else {
                print("SignUp Complete")
                return signUpResult
            }
        } catch let error as AuthError {
            print("An error occurred while registering a user \(error)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    func confirmSignUp(for username: String, with confirmationCode: String) async throws -> AuthSignUpResult {
        do {
            let confirmSignUpResult = try await Amplify.Auth.confirmSignUp(
                for: username,
                confirmationCode: confirmationCode
            )
            print("Confirm sign up result completed: \(confirmSignUpResult.isSignUpComplete)")
            return confirmSignUpResult
        } catch let error as AuthError {
            print("An error occurred while confirming sign up \(error)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    func signIn(username: String, password: String) async throws -> AuthSignInResult {
        do {
            let signInResult = try await Amplify.Auth.signIn(
                username: username,
                password: password
                )
            if signInResult.isSignedIn {
                print("Sign in succeeded")
                return signInResult
            } else {
                return signInResult
            }
        } catch let error as AuthError {
            print("Sign in failed \(error)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
}
