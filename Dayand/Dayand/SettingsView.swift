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
    @State private var showingAlert = false
    
    @State var remindersEnabled = UserDefaults.standard.bool(forKey: "DayandRemindersEnabled")
    @State var reminderCadence = UserDefaults.standard.string(forKey: "DayandReminderCadence")
    @State var cadenceTime = UserDefaults.standard.string(forKey: "DayandReminderCadenceTime") ?? "30"
    @State private var fromHour = Date()
    @State private var toHour = Date()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Settings")
                .font(.largeTitle)
                .foregroundColor(Color(.textColor))
                .padding(.bottom, 20)
                
            HStack(alignment: .center, spacing: 16) {
                Toggle("", isOn: $remindersEnabled)
                    .onReceive([self.remindersEnabled].publisher.first()) { (value) in
                        if(remindersEnabled != UserDefaults.standard.bool(forKey: "DayandRemindersEnabled")) {
                            changesMade = true
                        }
                            self.remindersEnabled = value
                }
                .toggleStyle(CustomToggle())
                .frame(width: 31, height: 20)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notification reminders")
                        .fontWeight(.bold)
                    
                    Text("Select how often and when you'd like receive notifications to log activity.")
                        .foregroundColor(Color(.gray))
                }
            }
            .contentShape(Rectangle())
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
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color(.textColor))
                        .background(Color("backgroundColor"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color(.systemGray).opacity(0.4), lineWidth: 1)
                                .shadow(color: Color(.shadowColor).opacity(0.2),
                                                                radius: 1, x: 0, y: 1)
                                                  
                        )
                        .cornerRadius(9)
                        
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
                                RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color(.systemGray).opacity(0.4), lineWidth: 1)
                            )
                            .cornerRadius(7)
                            .shadow(color: Color(.shadowColor).opacity(0.2), radius: 1, x: 0, y: 1)
                            
                            Text("\(reminderCadence ?? "hours")")
                                .font(.headline)
                                .fontWeight(.medium)
                                .multilineTextAlignment(.center)
                                .padding(.leading, 11.0)
                                .allowsHitTesting(false)
                        }
                    }
                    
                    HStack {
                        Text("Between")
                        
                        DatePicker(selection: .constant(fromHour), displayedComponents: .hourAndMinute, label: { Text("") })
                            .datePickerStyle(FieldDatePickerStyle())
                            .frame(width: 90, height: 38)
                            .cornerRadius(7)
                        
                        Text("and")

                        DatePicker(selection: .constant(toHour), displayedComponents: .hourAndMinute, label: { Text("") })
                            .datePickerStyle(FieldDatePickerStyle())
                            .frame(width: 90, height: 38)
                            .cornerRadius(7)
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 30, maxHeight:.infinity)
                .padding()
                .padding(.leading, 32)
//                .background(Color(.textColor).opacity(0.03))
                .cornerRadius(9)
                .allowsHitTesting(remindersEnabled)
                .opacity(remindersEnabled ? 1.0 : 0.5)
            }
            
            Divider()
            
            // Footer
            
            HStack() {
                CustomButtonView(title: "Reset Dayand", action: { showingAlert = true }, disabledState: false, buttonClass: "Destructive").alert(isPresented: $showingAlert) {
                    Alert(title: Text("Are you sure?"), message: Text("This will reset all settings and remove all saved data. This action cannot be undone."), primaryButton: Alert.Button.default(Text("Reset")) {
                        
                        // Would clear all settings and saved data
                        
                        ResetTheApp()
                        
                    }, secondaryButton: .default(Text("Cancel")))
                }
                
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
    
    func ResetTheApp() {
        
        // Delete all activity entries
        
        if entries.count > 0 {
            for index in 0...entries.count {
                moc.delete(entries[index])
            }
            try? self.moc.save()
        } else {
            print("Nothing to do")
        }
        
        // Remove all user settings
        
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        
        // Cancel any pending notifications
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Close the settings window as confirmation
        
        NSApplication.shared.keyWindow?.close()
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
                
//                for index in 6...19 {
//                    let randomMinute = Int.random(in: 1..<50)
//
//                    var dateComponents = DateComponents()
//                    dateComponents.hour = index
//                    dateComponents.minute = randomMinute
//                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//                    center.add(request)
//                    print("Scheduled notification for \(index):\(randomMinute)")
//                }
                
                // Repeating at a specific time
                
        //        var dateComponents = DateComponents()
        //        dateComponents.hour = 10
        //        dateComponents.minute = 30
        //        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

                // Scheduling every n minutes
                
                let scheduledRecurrance:TimeInterval = 60.0 * (Double(cadenceTime) ?? 1)
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: scheduledRecurrance, repeats: true)
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                center.add(request)
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
