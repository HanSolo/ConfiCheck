//
//  AppDelegate.swift
//  Sugr
//
//  Created by Gerrit Grunwald on 09.01.25.
//

import Foundation
import SwiftUI
import UserNotifications


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        debugPrint("AppDelegate.didFinishWithOptions called")
        application.registerForRemoteNotifications()

        return true
    }
      

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        //Properties.instance.deviceId = token
        debugPrint("deviceId: \(token)")        
    }
}
