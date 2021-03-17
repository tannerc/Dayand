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
    @State var reminderCadence = UserDefaults.standard.integer(forKey: "DayandReminderCadence")
    @State var reminderStart = UserDefaults.standard.object(forKey: "DayandReminderStartTime") as! Date
    @State var reminderEnd = UserDefaults.standard.object(forKey: "DayandReminderEndTime") as! Date
    
    var body: some View {
        VStack(alignment: .leading) {
            
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
                        HStack(spacing: 0) {
                            ZStack(alignment: .leading) {
                                MenuButton("") {
                                    Button(action: { ChangeReminderCadence(toCadence: 1) }, label: {
                                        Text("1 reminder")
                                    })
                                    
                                    Button(action: { ChangeReminderCadence(toCadence: 2) }, label: {
                                        Text("2 reminders")
                                    })
                                    
                                    Button(action: { ChangeReminderCadence(toCadence: 3) }, label: {
                                        Text("3 reminders")
                                    })
                                    
                                    Button(action: { ChangeReminderCadence(toCadence: 4) }, label: {
                                        Text("4 reminders")
                                    })
                                    
                                    Button(action: { ChangeReminderCadence(toCadence: 5) }, label: {
                                        Text("5 reminders")
                                    })
                                    
                                    Button(action: { ChangeReminderCadence(toCadence: 6) }, label: {
                                        Text("6 reminders")
                                    })
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
                                
                                Text(reminderCadence == 1 ? "\(reminderCadence) reminder" : "\(reminderCadence) reminders")
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.leading, 11.0)
                                    .allowsHitTesting(false)
                            }
                            
                            Text("between")
                                .padding(.leading, 12)
                            
                            DatePicker(selection: $reminderStart, displayedComponents: .hourAndMinute, label: { Text("") })
                                .datePickerStyle(FieldDatePickerStyle())
                                .frame(width: 90, height: 38)
                                .cornerRadius(7)
                                .focusable()
                            
                            Text("and")
                                .padding(.leading, 8)

                            DatePicker(selection: $reminderEnd, displayedComponents: .hourAndMinute, label: { Text("") })
                                .datePickerStyle(FieldDatePickerStyle())
                                .frame(width: 90, height: 38)
                                .cornerRadius(7)
                                .focusable()
                            
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
            }
            .padding(20)
            
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
            .padding(20)
            .background(Color(.textColor).opacity(0.02))
//            .buttonStyle(PlainButtonStyle())
        }
//        .padding(20)
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
        
    func ChangeReminderCadence(toCadence: Int) {
        UserDefaults.standard.setValue(toCadence, forKey: "DayandReminderCadence")
        reminderCadence = toCadence
        changesMade = true
    }
    
    func ResetTheApp() {
        
        // Delete all activity entries
        
        print("Reseting...")
        
        if entries.count > 0 {
            print("1. Trying to delete entries...")
            
            for index in 0...entries.count-1 {
                moc.delete(entries[index])
            }
            try? self.moc.save()
        } else {
            print("1. Nothing to do")
        }
        
        // Remove all user settings
        
        if let appDomain = Bundle.main.bundleIdentifier {
            
            print("2. Trying to reset userdefaults...")
            
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UserDefaults.standard.set(Date(), forKey: "DayandReminderStartTime")
            UserDefaults.standard.set(Date(), forKey: "DayandReminderEndTime")
            UserDefaults.standard.set(7, forKey: "DayandChartRange")
            UserDefaults.standard.set(2, forKey: "DayandReminderCadenceTime")
        }
        
        // Cancel any pending notifications
        
        print("3. Clearing notifications...")
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Close the settings window as confirmation
        
        print("4. Closing window")
        
        NSApplication.shared.keyWindow?.close()
    }
    
    func CheckNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                remindersEnabled = true
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                ScheduleNotifications()
            } else {
//                Alert(title: Text("Notifications not enabled"), message: Text("Dayand does not have permission to enable notifications. Please check your system settings to continue."), dismissButton: .default(Text("Ok")))
                remindersEnabled = false
            }
        }
    }
    
    func ScheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        
        // Create the content for notifications, using a random string for title and body.
        
        let titleArray = ["Log activity",
                          "What are you doing now?",
                          "Where is your focus?",
                          "Capture this moment",
                          "What's important in this moment?"]
        
        let bodyArray = ["Use Dayand to log what you're doing now and your reaction to it.",
                            "Capture your activity and response now.",
                            "How are you feeling about what you're doing now?",
                            "Take one minute to log your activity.",
                            "Take note of what you're doing and how you feel."]
        
        let content = UNMutableNotificationContent()
        content.title = titleArray.randomElement() ?? "Log activity"
        content.body = bodyArray.randomElement() ?? "Use Dayand to log what you're doing now and your reaction to it."
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        
        // Scheduling random minutes between the times set by reminderStart and reminderEnd.
                        
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderStart)
        let startMinute = startComponents.minute ?? 30
        
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: reminderEnd)
        var endMinute = endComponents.minute ?? 30
        
        if (endMinute == 1){
            endMinute = 2
        }
        
        let hoursdiff = Calendar.current.dateComponents([.hour], from: startComponents, to: endComponents)
        var hoursbetween = Int(hoursdiff.hour ?? 1)
        
        if (hoursbetween < 0) {
            hoursbetween *= -1
        }
        
        print("SHOULD SCHEDULE \(hoursbetween*reminderCadence) NOTIFICATIONS BETWEEN \(String(describing: startComponents.hour)):\(String(describing: startComponents.minute)) AND \(String(describing: endComponents.hour)):\(String(describing: endComponents.minute))")
        
        // Loop through the hours to generate prompts at the proper cadence
                        
        for index in 0...hoursbetween {
            var randomMinute: Int
            var prevMinute: Int = 1
            
            // Generate the minute for each hour
            
            if reminderCadence < 1 {
                reminderCadence = 2
                UserDefaults.standard.setValue(2, forKey: "DayandReminderCadence")
            }
            
            // For each cadence, assign an hour and minute value
            
            for _ in 1...reminderCadence {
                
                randomMinute = Int.random(in: 1..<59)
                
                if (index == 0 && randomMinute < startMinute) {
                    randomMinute = Int.random(in: 1..<59) + 1
                }
                
                if (randomMinute == prevMinute) {
                    randomMinute = Int.random(in: 1..<59)
                }
                
                if (index == hoursbetween && randomMinute > endMinute) {
                    randomMinute = endMinute
                }
                
                let tempInt = index * (60 * 60)
                let tempComponents = Calendar.current.dateComponents([.hour], from: reminderStart.addingTimeInterval(TimeInterval(tempInt)))
                
                var dateComponents = DateComponents()
                dateComponents.hour = tempComponents.hour
                dateComponents.minute = randomMinute
                
                let diggity = UUID().uuidString
                
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(5*index2), repeats: true)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: diggity, content: content, trigger: trigger)
                center.add(request)
                
                prevMinute = randomMinute
            }
        }
        
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
//            for item in notifications {
//              print(item.content)
//            }
        }
    }
    
    func SaveAllChanges() {
        UserDefaults.standard.set(remindersEnabled, forKey: "DayandRemindersEnabled")
        
        if !remindersEnabled {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            UserDefaults.standard.set(reminderStart, forKey: "DayandReminderStartTime")
            UserDefaults.standard.set(reminderEnd, forKey: "DayandReminderEndTime")
            UserDefaults.standard.set(reminderCadence, forKey: "DayandReminderCadenceTime")
            CheckNotificationPermissions()
        }
        
        UserDefaults.standard.set(reminderCadence, forKey: "DayandReminderCadence")
        NSApplication.shared.keyWindow?.close()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environment(\.colorScheme, .light)
    }
}
