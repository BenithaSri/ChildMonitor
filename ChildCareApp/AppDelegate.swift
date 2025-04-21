//
//  AppDelegate.swift
//  ChildCareApp
//
//  Created by Benitha on 29/01/2025.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase

@main


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        appLaunchTime =  Date().timeIntervalSince1970
        
        FirebaseApp.configure()
        //AIzaSyBs9-KIgaZwl3N5DJ6WYL7VRNUrJhYjveM
        GMSServices.provideAPIKey(mapKey)
        GMSPlacesClient.provideAPIKey(mapKey)
        
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("Notification permission granted.")
                }
            }
            application.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
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

