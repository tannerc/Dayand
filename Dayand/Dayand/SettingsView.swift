//
//  SettingsView.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/23/21.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

struct SettingsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Dataobject.entity(), sortDescriptors: []) var entries: FetchedResults<Dataobject>
    
    @State var colorSyncFormat = UserDefaults.standard.string(forKey: "superbcolorcopyformat")
    
    @State private var changesMade = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(Color(.textColor))
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Copy colors in this format").font(.caption)
                        
                        MenuButton("\(colorSyncFormat ?? "Hex value")") {
                            Button(action: {
                                ChangeColorCopyFormat(toValue: "Hex value")
                                self.colorSyncFormat = UserDefaults.standard.string(forKey: "superbcolorcopyformat")
                            }) {
                                Text("Hex value")
                            }
                            
                            Button(action: {
                                ChangeColorCopyFormat(toValue: "RGB value")
                                self.colorSyncFormat = UserDefaults.standard.string(forKey: "superbcolorcopyformat")
                            }) {
                                Text("RGB value")
                            }
                            
                            Button(action: {
                                ChangeColorCopyFormat(toValue: "Color name")
                                self.colorSyncFormat = UserDefaults.standard.string(forKey: "superbcolorcopyformat")
                            }) {
                                Text("Color name")
                            }
                        }.frame(width: 140).shadow(color: Color(.lightGray).opacity(0.2), radius: 2, x: 0, y: 3)
                    }
                    
                    Button(action: {
                        DeleteAllEntries()
                    }) {
                        Text("Clear " + GetAllEntries())
                    }.disabled(entries.count > 0 ? false : true)
                    
                    Button(action: {
                        DisplayNotification()
                    }) {
                        Text("Do notification!")
                    }
                    
                    Button(action: {
                       UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    }) {
                        Text("Clear all notifications")
                    }

                    Spacer()
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            
            HStack() {
                Spacer()
                
                CustomButtonView(title: "Cancel", action: { NSApplication.shared.keyWindow?.close() }, disabledState: false, buttonClass: "Default")
                CustomButtonView(title: "Save", action: { NSApplication.shared.keyWindow?.close() }, disabledState: !changesMade, buttonClass: "Primary")
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(Color("backgroundColor"))
    }
    
    func GetAllEntries() -> String {
        
        if entries.isEmpty {
            return "0 activities"
        } else {
            var suffixString = ""
            
            if entries.count == 1 {
                suffixString = "activity"
            } else {
                suffixString = "activities"
            }

            return String("\(String(entries.count)) \(suffixString)")
        }
    }
    
    func DeleteAllEntries() {
//        let center = UNUserNotificationCenter.current()
//        center.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { granted, error in
//
//            if let error = error {
//                // Handle the error here.
//            }
//
//            // Provisional authorization granted.
//        }
        
        for index in 0...entries.count-1 {
            moc.delete(entries[index])
        }
        try? self.moc.save()
        print("Done!")
        
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
    
    func DisplayNotification() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
                scheduleNotification()
            } else {
                print("D'oh")
            }
        }
    }
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Time to log your activity"
        content.body = "Use Dayand to log what you're doing now and your reaction to it."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        // Scheduling random times between 6am and 7pm
        
        for index in 6...19 {
//            let randomHour = Int.random(in: 6..<19)
            let randomMinute = Int.random(in: 1..<50)
            
            var dateComponents = DateComponents()
            dateComponents.hour = index
            dateComponents.minute = randomMinute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            print("Scheduled notification for \(index):\(randomMinute)")
        }
        
        // Repeating at a specific time
//        var dateComponents = DateComponents()
//        dateComponents.hour = 10
//        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Show five seconds after created
        
        
        
//        var dateComponents = DateComponents()
//        dateComponents.hour = 10
//        dateComponents.minute = 30
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: true)
//
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        center.add(request)
    }
}

func ChangeColorCopyFormat(toValue: String) {
    UserDefaults.standard.set(toValue, forKey: "superbcolorcopyformat")
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environment(\.colorScheme, .light)
    }
}
