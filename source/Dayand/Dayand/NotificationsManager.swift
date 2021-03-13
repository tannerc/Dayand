//
//  NotificationsManager.swift
//  Dayand
//
//  Created by Tanner Christensen on 3/12/21.
//

import Foundation
import UserNotifications
import SwiftUI

struct NotificationsManager {
    
    func CheckNotificationPermissions() -> Bool {
        let center = UNUserNotificationCenter.current()
        var returnVal: Bool = false
                
        center.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                
                print("Requesting permissions...")
                
                // Need to get permission for notifications
                
                center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                    if granted {
                        returnVal = true
                    } else {
                        returnVal = false
                    }
                }
            } else if settings.authorizationStatus == .denied {
                
                print("Notification permission not authorized")
                
                // Notifications not currently authorized, display a prompt for the user
                
                DisplayNotifPreferencesAlert()
                                
                returnVal = false
                
            } else if settings.authorizationStatus == .authorized {
                
                print("Already authorized")
                
                // Already authorized, set the notifications!
                
                returnVal = true
            }
        })
        
        return returnVal
    }

    func DisplayNotifPreferencesAlert() {
        DispatchQueue.main.async {
            let question = "Could not save changes while quitting. Quit anyway?"
            let info = "Allow Dayand to send "
            let primaryButton = "Open Preferences"
            let cancelButton = "Cancel"
            
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: primaryButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertFirstButtonReturn {
//                self.openURL(URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!)
            }
        }
    }
    
    func ScheduleNotifications(fromTime: Date, toTime: Date) {
        let center = UNUserNotificationCenter.current()
        
        // Clear any existing notifications
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Create the content for notifications
        
        let content = UNMutableNotificationContent()
        content.title = "Time to log activity"
        content.body = "Use Dayand to log what you're doing now and your reaction to it."
        content.categoryIdentifier = "alert"
        content.sound = UNNotificationSound.default
        
        // Scheduling random minutes between the times set by reminderStart and reminderEnd
                        
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: fromTime)
        let startMinute = startComponents.minute ?? 30
        
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: toTime)
        var endMinute = endComponents.minute ?? 30
        
        if (endMinute == 1){
            endMinute = 2
        }
        
        let hoursdiff = Calendar.current.dateComponents([.hour], from: startComponents, to: endComponents)
        var hoursbetween = Int(hoursdiff.hour ?? 1)
        
        if (hoursbetween < 0) {
            hoursbetween *= -1
        }
                        
        for index in 0...hoursbetween {
            var randomMinute: Int
            
            // Generate the hour, twice so user gets at least two notifications every hour
            
            for _ in 1...2 {
                randomMinute = Int.random(in: 1..<59)
                
                if index == 0 {
                    randomMinute = startMinute
                }
                
                let tempInt = index * (60 * 60)
                let tempComponents = Calendar.current.dateComponents([.hour], from: fromTime.addingTimeInterval(TimeInterval(tempInt)))

                var dateComponents = DateComponents()
                dateComponents.hour = tempComponents.hour
                dateComponents.minute = randomMinute
                                    
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
            }
        }
        
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
            for item in notifications {
              print(item.content)
            }
        }
        
        DispatchQueue.main.async {
            NSApplication.shared.keyWindow?.close()
        }
    }
    
    func ClearAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
