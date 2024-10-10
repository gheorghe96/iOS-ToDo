//
//  NotificationsManager.swift
//  todo
//
//  Created by Gheorghe on 22.09.2024.
//

import UserNotifications

struct NotificationPayload {
    var id: UUID
    var date: Date
    var title: String?
    var description: String?
}

struct NotificationsManager {
    func scheduleNotification(_ payload: NotificationPayload) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = payload.title ?? "Reminder"
                content.body = payload.description ?? "This is your scheduled notification."
                content.sound = .default
                
                // Extract date components (year, month, day, hour, minute) from the target date
                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: payload.date)
                
                // Create a trigger that will fire at the specific time
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                
                // Create a request with a unique identifier
                let request = UNNotificationRequest(identifier: payload.id.uuidString, content: content, trigger: trigger)
                
                // Schedule the notification
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            } else {
                print("Permission denied")
            }
        }
    }
    
    func removeAllScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All scheduled notifications have been removed.")
    }
    
    func removePendingNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
