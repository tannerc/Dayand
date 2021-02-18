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
    
    @State private var changesMade = false
    
    @State var remindersEnabled = UserDefaults.standard.bool(forKey: "DayandRemindersEnabled")
    @State var reminderCadence = UserDefaults.standard.string(forKey: "DayandReminderCadence")
    @State var cadenceTime = UserDefaults.standard.string(forKey: "DayandReminderCadenceTime") ?? "30"
    @State private var fromHour = Date()
    @State private var toHour = Date()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(Color(.textColor))
                
            VStack(alignment: .leading) {
                
                HStack(alignment: .top) {
                    Toggle("", isOn: $remindersEnabled)
                        .onReceive([self.remindersEnabled].publisher.first()) { (value) in
                            if(remindersEnabled != UserDefaults.standard.bool(forKey: "DayandRemindersEnabled")) {
                                changesMade = true
                            }
                                self.remindersEnabled = value
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Some text")
                            .fontWeight(.bold)
                        
                        Text("And a bit more text goes here")
                    }
                }
                .onTapGesture {
                    remindersEnabled.toggle()
                }
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("Every")
                        
                            HStack {
                                TextField("30", text: $cadenceTime)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .frame(width: 60, height: 38)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(.textColor))
                            .background(Color("backgroundColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color(.systemGray).opacity(0.4), lineWidth: 1)
                                    .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),
                                                                    radius: 1, x: 0, y: 1)
                                                      
                            )
                            .cornerRadius(5)
                            
                            ZStack(alignment: .leading) {
                                MenuButton("") {
                                    Button(action: {
                                        reminderCadence = "minutes"
                                        changesMade = true
                                    }) {
                                        Text("minutes")
                                    }
                                    
                                    Button(action: {
                                        reminderCadence = "hours"
                                        changesMade = true
                                    }) {
                                        Text("hours")
                                    }
                                }
                                .contentShape(Rectangle())
                                .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                                .frame(width: 132, height: 38, alignment: .trailing)
                                .background(Image("DownTriangleImage").resizable().frame(width: 24, height: 24).foregroundColor(Color(.textColor)).scaleEffect(0.9).padding(8), alignment: .trailing)
                                .background(Color("backgroundColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 9)
                                        .stroke(Color(.systemGray).opacity(0.4), lineWidth: 1)
                                )
                                .cornerRadius(9)
                                .shadow(color: Color(.shadowColor).opacity(0.2), radius: 1, x: 0, y: 1)
                                
                                Text("\(reminderCadence ?? "hours")")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.leading, 11.0)
                                    .allowsHitTesting(false)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("Between")
                            
                            HStack {
                                DatePicker(selection: .constant(fromHour), displayedComponents: .hourAndMinute, label: { Text("") })
                                    .datePickerStyle(FieldDatePickerStyle())
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .frame(width: 100, height: 38)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(.textColor))
                            .background(Color("backgroundColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color(.systemGray).opacity(0.4), lineWidth: 1)
                                    .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),
                                                                    radius: 1, x: 0, y: 1)
                                                      
                            )
                            .cornerRadius(5)
                            
                            Text("and")
 
                            HStack {
                                DatePicker(selection: .constant(toHour), displayedComponents: .hourAndMinute, label: { Text("") })
                                    .datePickerStyle(FieldDatePickerStyle())
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 8)
                            .frame(width: 100, height: 38)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(Color(.textColor))
                            .background(Color("backgroundColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color(.systemGray).opacity(0.4), lineWidth: 1)
                                    .shadow(color: Color(red: 192/255, green: 189/255, blue: 191/255),
                                                                    radius: 1, x: 0, y: 1)
                                                      
                            )
                            .cornerRadius(5)
                            
                            Spacer()
                        }

                        Spacer()
                    }
                    .frame(minWidth: 200, maxWidth: .infinity, minHeight: 60, maxHeight:.infinity)
                    .padding()
                    .background(Color(.textColor).opacity(0.03))
                    .cornerRadius(9)
                    .allowsHitTesting(remindersEnabled)
                    .opacity(remindersEnabled ? 1.0 : 0.5)
                    
                                    }
            }
            .padding(.vertical, 12)
            
            Button(action: {
                DeleteAllEntries()
            }) {
                Text("Clear " + GetAllEntries())
            }.disabled(entries.count > 0 ? false : true)
            
            Button(action: {
                ScheduleNotifications()
            }) {
                Text("Do notification!")
            }
            
            Button(action: {
               UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            }) {
                Text("Clear all notifications")
            }
            
            
            // Footer
            
            HStack() {
                CustomButtonView(title: "Reset Dayand", action: { NSApplication.shared.keyWindow?.close() }, disabledState: false, buttonClass: "Destructive")
                
                Spacer()
                
                CustomButtonView(title: "Cancel", action: { NSApplication.shared.keyWindow?.close() }, disabledState: false, buttonClass: "Default")
                CustomButtonView(title: "Save Changes", action: { SaveAllChanges() }, disabledState: !changesMade, buttonClass: "Primary")
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
    
    func ScheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
            for item in notifications {
              print(item.content)
            }
        }
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
                
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
            } else {
                print("D'oh")
            }
        }
    }
    
    func SaveAllChanges() {
        
        UserDefaults.standard.set(remindersEnabled, forKey: "DayandRemindersEnabled")
        
        if !remindersEnabled {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            ScheduleNotifications()
            UserDefaults.standard.set(cadenceTime, forKey: "DayandReminderCadenceTime")
        }
        
        UserDefaults.standard.set(reminderCadence, forKey: "DayandReminderCadence")
//        self.reminderCadence = UserDefaults.standard.string(forKey: "DayandReminderCadence")
        NSApplication.shared.keyWindow?.close()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environment(\.colorScheme, .light)
    }
}
