//
//  ActivityView.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/25/21.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications

struct ActivityView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Dataobject.entity(),
                  sortDescriptors:
                    [NSSortDescriptor(keyPath: \Dataobject.logdate, ascending: false)]
    ) var entries: FetchedResults<Dataobject>
    
    @State var colorSyncFormat = UserDefaults.standard.string(forKey: "superbcolorcopyformat")
    
    @State private var changesMade = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Activity")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(Color(.textColor))
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    List {
                        ForEach(entries, id: \.self) { (loggedentry: Dataobject) in
                            Text(loggedentry.message ?? "No message")
                            Text(String(loggedentry.response))
                            Text(String(loggedentry.date))
                        }
                    }

                    Spacer()
                }
                
                Spacer()
            }
            .padding(.vertical, 12)
            
            HStack() {
                Spacer()
                
                DayandButton(title: "Cancel", action: { NSApplication.shared.keyWindow?.close() }, backgroundColor: Color(.systemGray).opacity(0.4), disabledState: false)
                
                DayandButton(title: "Save changes", action: { NSApplication.shared.keyWindow?.close() }, backgroundColor: Color(.systemBlue), disabledState: !changesMade)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
//        .background(Color(.highlightColor))
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
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        
        // Repeating at a specific time
//        var dateComponents = DateComponents()
//        dateComponents.hour = 10
//        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        // Show five seconds after created
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView().environment(\.colorScheme, .light)
    }
}
