//
//  NotificationsViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 2/7/25.
//

import UIKit
import UserNotifications

class NotificationsViewController: UIViewController, UNUserNotificationCenterDelegate {

    // IBOutlet for the toggle switch
    @IBOutlet weak var notificationToggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request notification permission
        requestNotificationPermission()
        
        // Set the delegate for notifications
        UNUserNotificationCenter.current().delegate = self
        
        // Set the initial state of the switch
        notificationToggle.isOn = false
    }

    // Request notification permission for badges, sounds, and alerts
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }

    // Toggle switch action to start/stop notifications
    @IBAction func toggleSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            scheduleTextAlertBadge()
        } else {
            cancelScheduledNotifications()
        }
    }
    
    // Schedule the text alert badge every 2 minutes
    func scheduleTextAlertBadge() {
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "This is a scheduled text alert badge."
        content.sound = .default
        content.badge = NSNumber(value: 1) // Set the badge to 1 when the notification is fired

        // Create a trigger to repeat every 2 minutes
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)

        // Create the notification request
        let request = UNNotificationRequest(identifier: "TextAlertBadge", content: content, trigger: trigger)

        // Add the notification request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled!")
            }
        }
    }

    // Cancel all scheduled notifications (when toggle is off)
    func cancelScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TextAlertBadge"])
        UIApplication.shared.applicationIconBadgeNumber = 0 // Reset badge number
        print("Scheduled notifications canceled")
    }
    
    // Handle notifications when app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    // Handle notification when app is in the background or closed
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Reset badge after notification tap
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }
}
