//
//  AppDelegate.swift
//  AppCovid
//
//  Created by Alan Zavala on 16/04/20.
//  Copyright © 2020 Alan Zavala. All rights reserved.
//

import UIKit
import ApiAI
import AVFoundation
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let configuration = AIDefaultConfiguration()
        configuration.clientAccessToken = "e50a50d58bd44cc2b16fe2f0f0c36b7c"
        
        let apiai = ApiAI.shared()
        apiai?.configuration = configuration
        
//        UIApplication.shared.statusBarStyle = .lightContent

        FirebaseApp.configure()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

