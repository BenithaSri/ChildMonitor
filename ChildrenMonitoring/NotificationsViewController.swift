//
//  NotificationsViewController.swift
//  ChildrenMonitoring
//
//  Created by Benitha Sri Panchagiri on 2/7/25.
//

import UIKit
import UserNotifications

class NotificationsViewController: UIViewController, UNUserNotificationCenterDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var notificationToggle: UISwitch!
    @IBOutlet weak var tableView: UITableView!

    struct NotificationItem {
        let title: String
        let body: String
        let timestamp: Date
    }

    var notificationHistory: [NotificationItem] = [] {
        didSet {
            // Sort notifications by timestamp, newest first
            notificationHistory.sort { $0.timestamp > $1.timestamp }
            saveNotifications()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        requestNotificationPermission()
        UNUserNotificationCenter.current().delegate = self
        notificationToggle.isOn = false
        
        // Load any previously saved notifications
        loadSavedNotifications()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120 // Adjust this to fit your content
    }

    // Request notification permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.notificationToggle.isEnabled = granted
                if !granted {
                    self.showPermissionAlert()
                }
            }
        }
    }

    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Notifications Disabled",
            message: "Please enable notifications in Settings to receive alerts.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // Toggle switch action
    @IBAction func toggleSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            scheduleTextAlertBadge()
        } else {
            cancelScheduledNotifications()
        }
    }

    // Schedule notification
    func scheduleTextAlertBadge() {
        let content = UNMutableNotificationContent()
        content.title = "Child Activity Alert"
        content.body = "New activity detected"
        content.sound = .default
        content.badge = NSNumber(value: 1)

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let request = UNNotificationRequest(identifier: "TextAlertBadge", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }

    // Handle notifications when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        addNewNotification(notification)
        completionHandler([.alert, .badge, .sound])
    }

    // Handle notification when app is in background
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        addNewNotification(response.notification)
        UIApplication.shared.applicationIconBadgeNumber = 0
        completionHandler()
    }

    private func addNewNotification(_ notification: UNNotification) {
        let newNotification = NotificationItem(
            title: notification.request.content.title,
            body: notification.request.content.body,
            timestamp: notification.date
        )

        // Add to history and trigger didSet observer
        notificationHistory.append(newNotification)
    }

    // Save notifications to UserDefaults
    private func saveNotifications() {
        let notificationsData = notificationHistory.map { [
            "title": $0.title,
            "body": $0.body,
            "timestamp": $0.timestamp.timeIntervalSince1970
        ] }
        UserDefaults.standard.set(notificationsData, forKey: "notifications")
    }

    // Load notifications from UserDefaults
    private func loadSavedNotifications() {
        if let savedData = UserDefaults.standard.array(forKey: "notifications") as? [[String: Any]] {
            notificationHistory = savedData.compactMap { dict in
                guard let title = dict["title"] as? String,
                      let body = dict["body"] as? String,
                      let timestamp = dict["timestamp"] as? TimeInterval else {
                    return nil
                }
                return NotificationItem(
                    title: title,
                    body: body,
                    timestamp: Date(timeIntervalSince1970: timestamp)
                )
            }
        }
    }

    // MARK: - TableView DataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let notification = notificationHistory[indexPath.row]

        cell.configure(
            with: notification.title,
            body: notification.body,
            date: notification.timestamp
        )

        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notificationHistory.remove(at: indexPath.row)
        }
    }

    // MARK: - Cancel Notifications
    func cancelScheduledNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["TextAlertBadge"])
        UIApplication.shared.applicationIconBadgeNumber = 0 // Reset badge number
        print("Scheduled notifications canceled")
    }
}
