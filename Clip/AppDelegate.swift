//
//  AppDelegate.swift
//  Clip
//
//  Created by Riley Testut on 6/10/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import UIKit
import UserNotifications

import ClipKit
import Roxas

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        
        print(RoxasVersionNumber)
        
        self.window?.tintColor = .clipPink
        
        UserDefaults.shared.registerAppDefaults()
        
        func printError<T>(from result: Result<T, Error>, title: String)
        {
            guard let error = result.error else { return }
            print(title, error)
        }
        
        DatabaseManager.shared.prepare() { printError(from: $0, title: "Database Error:") }
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
        }
        
        ApplicationMonitor.shared.start()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        #if targetEnvironment(simulator)
        // Audio extension hack to access pasteboard doesn't work in simulator, so for testing just start background task.
        RSTBeginBackgroundTask("com.rileytestut.Clip.simulatorBackgroundTask")
        #endif
        
        DatabaseManager.shared.purge()
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        DatabaseManager.shared.refresh()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate
{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}