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
import AWSCognitoAuthPlugin

class AmplifyAuthService: ObservableObject {
    static let shared = AmplifyAuthService()
    @AppStorage("isSignedIn") var isSignedIn = false
    
    func checkSessionStatus() async {
        do {
            let result = try await Amplify.Auth.fetchAuthSession()
            if result.isSignedIn {
                self.isSignedIn = true
                print("In Session")
            } else {
                let appDomain = Bundle.main.bundleIdentifier
                UserDefaults.standard.removePersistentDomain(forName: appDomain!)
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
    
    func signUp(username: String, password: String, name: String, email: String = "", groupID: String = "") async throws -> AuthSignUpResult {
        var userAttributes = [AuthUserAttribute(.name, value: name)]
        if !email.isEmpty {
            userAttributes.append(AuthUserAttribute(.email, value: email))
        }
        if !groupID.isEmpty {
            userAttributes.append(AuthUserAttribute(.custom("InvitedGroupID"), value: groupID))
        }
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
            switch error {
            case .configuration(_, _, _):
                print("configuration exception")
                print(error)
            case .service(let description, _, _):
                if description.contains("User already exists") {
                    throw AmplifyAuthError.userAlreadyExists
                }
                print("service exception")
                print(error)
            case .unknown(_, _):
                print("unknown exception")
                print(error)
            case .validation(_, _, _, _):
                print("validation exception")
                print(error)
            case .notAuthorized(_, _, _):
                print("notAuthorized exception")
                print(error)
            case .invalidState(_, _, _):
                print("invalidState exception")
                print(error)
            case .signedOut(_, _, _):
                print("signedOut exception")
                print(error)
            case .sessionExpired(_, _, _):
                print("sessionExpired exception")
                print(error)
            }
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
            switch error {
            case .configuration(_, _, _):
                print("configuration exception")
                print(error)
            case .service(let description, _, _):
                print("service exception")
                print(error)
                if description.contains("Invalid verification code"){
                    throw AmplifyAuthError.notAuthorized
                }
            case .unknown(_, _):
                print("unknown exception")
                print(error)
            case .validation(_, _, _, _):
                print("validation exception")
                print(error)
            case .notAuthorized(let description, _, _):
                /// 認証コード2回目打鍵した時もここ
                if description.contains("Invalid verification code"){
                    throw AmplifyAuthError.notAuthorized
                }
            case .invalidState(_, _, _):
                print("invalidState exception")
                print(error)
            case .signedOut(_, _, _):
                print("signedOut exception")
                print(error)
            case .sessionExpired(_, _, _):
                print("sessionExpired exception")
                print(error)
            }
            print("An error occurred while confirming sign up \(error)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    func resendSignUpCode(for username: String) async throws {
        do {
            let authCodeDeliveryDetails = try await Amplify.Auth.resendSignUpCode(
                for: username
            )
            print("Auth code resend completed: \(authCodeDeliveryDetails.destination)")
        } catch let error as AuthError {
            switch error {
            case .configuration(_, _, _):
                print("configuration exception")
                print(error)
            case .service(let description, _, _):
                print("service exception")
                print(error)
                if description.contains("Invalid verification code"){
                    throw AmplifyAuthError.invalidVerificationCode
                }
                if description.contains("User is already confirmed"){
                    throw AmplifyAuthError.invalidVerificationCode
                }
            case .unknown(_, _):
                print("unknown exception")
                print(error)
            case .validation(_, _, _, _):
                print("validation exception")
                print(error)
            case .notAuthorized(_, _, _):
                print("notAuthorized exception")
                print(error)
            case .invalidState(_, _, _):
                print("invalidState exception")
                print(error)
            case .signedOut(_, _, _):
                print("signedOut exception")
                print(error)
            case .sessionExpired(_, _, _):
                print("sessionExpired exception")
                print(error)
            }
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
            print("Sign in succeeded")
            return signInResult
        } catch let error as AuthError {
            switch error {
            case .configuration(_, _, _):
                print("configuration exception")
                print(error)
            case .service(let description, _, _):
                print("service exception")
                print(error)
                if description.contains("User does not exist"){
                    throw AmplifyAuthError.notAuthorized
                }
            case .unknown(_, _):
                print("unknown exception")
                print(error)
            case .validation(_, _, _, _):
                print("validation exception")
                print(error)
            case .notAuthorized(let description, _, _):
                print("notAuthorized exception")
                print(error)
                if description.contains("Incorrect username or password"){
                    throw AmplifyAuthError.notAuthorized
                }
            case .invalidState(_, _, _):
                print("invalidState exception")
                print(error)
            case .signedOut(_, _, _):
                print("signedOut exception")
                print(error)
            case .sessionExpired(_, _, _):
                print("sessionExpired exception")
                print(error)
            }
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw error
        }
    }
    
    func signOutLocally() async throws {
        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult
        else {
            print("Signout failed")
            return
        }

        print("Local signout successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            // Sign Out completed fully and without errors.
            print("Signed out successfully")

        case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
            // Sign Out completed with some errors. User is signed out of the device.
            
            if let hostedUIError = hostedUIError {
                print("HostedUI error  \(String(describing: hostedUIError))")
            }

            if let globalSignOutError = globalSignOutError {
                // Optional: Use escape hatch to retry revocation of globalSignOutError.accessToken.
                print("GlobalSignOut error  \(String(describing: globalSignOutError))")
            }

            if let revokeTokenError = revokeTokenError {
                // Optional: Use escape hatch to retry revocation of revokeTokenError.accessToken.
                print("Revoke token error  \(String(describing: revokeTokenError))")
            }

        case .failed(let error):
            // Sign Out failed with an exception, leaving the user signed in.
            print("SignOut failed with \(error)")
            throw AmplifyAuthError.signOutFailed
        }
    }
    
//    func resendCode() async {
//        do {
//            let deliveryDetails = try await Amplify.Auth.resendConfirmationCode(forUserAttributeKey: .email)
//            print("Resend code send to - \(deliveryDetails)")
//        } catch let error as AuthError {
//            print("Resend code failed with error \(error)")
//        } catch {
//            print("Unexpected error: \(error)")
//        }
//    }
}
