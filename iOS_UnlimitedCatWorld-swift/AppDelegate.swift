//
//  AppDelegate.swift
//  iOS_UnlimitedCatWorld-swift
//
//  Created by Phil on 2025/4/9.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Appirater.setAppId("1000573724")
        Appirater.setDaysUntilPrompt(1)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)

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

    func applicationDidEnterBackground(_ application: UIApplication) {
        let gameScore = UserDefaults.standard.integer(forKey: "gameScore")
        GameCenterUtil.shared.reportScore(Int64(gameScore), forCategory: "com.irons.UnlimitedCatWorld")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Appirater.appEnteredForeground(true)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let gameScore = UserDefaults.standard.integer(forKey: "gameScore")
        GameCenterUtil.shared.reportScore(Int64(gameScore), forCategory: "com.irons.UnlimitedCatWorld")
    }
}
