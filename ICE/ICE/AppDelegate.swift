//
//  AppDelegate.swift
//  ICE
//
//  Created by 佐藤友貴 on 2023/10/09.
//

import UIKit
import Amplify
import Foundation
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin
import AWSAPIPlugin

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            try configureAmplify()
        } catch {
            print("Error configuring Amplify: \(error)")
        }
        return true
    }

    private func configureAmplify() throws {
        let configFile = Bundle.main.object(forInfoDictionaryKey: "amplify_configration_file")
        guard let url = Bundle.main.url(forResource: configFile as? String, withExtension: "json") else {
            throw ConfigurationError.missingConfig
        }
        let amplifyConfig = try AmplifyConfiguration(configurationFile: url)
        try Amplify.add(plugin: AWSCognitoAuthPlugin())
        try Amplify.add(plugin: AWSS3StoragePlugin())
        try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: AmplifyModels()))
        try Amplify.configure(amplifyConfig)
        print("Amplify configured with auth and api plugin")
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
