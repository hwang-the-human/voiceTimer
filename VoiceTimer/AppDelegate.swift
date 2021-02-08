//
//  AppDelegate.swift
//  VoiceTimer
//
//  Created by Nicholas HwanG on 4/15/20.
//  Copyright © 2020 Hwang. All rights reserved.
//

import UIKit
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let launch = UserDefaults.standard.integer(forKey: "launch")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().barTintColor = #colorLiteral(red: 0.139524132, green: 0.1401771903, blue: 0.1417474747, alpha: 1)
        UINavigationBar.appearance().tintColor = #colorLiteral(red: 0.9215686275, green: 0.9450980392, blue: 0.9843137255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        if launch >= 10 {
            SKStoreReviewController.requestReview()
            UserDefaults.standard.set(0, forKey: "launch")
        } else {
            UserDefaults.standard.set(launch + 1, forKey: "launch")
        }
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

