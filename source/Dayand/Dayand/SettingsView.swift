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
    @State var reminderStart = UserDefaults.standard.object(forKey: "DayandReminderStartTime") as! Date
    @State var reminderEnd = UserDefaults.standard.object(forKey: "DayandReminderEndTime") as! Date
    @State var cadenceTime = UserDefaults.standard.string(forKey: "DayandReminderCadenceTime") ?? "30"
    
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
                        HStack {
                            Group {
                                Text("Between")
                                
                                DatePicker(selection: $reminderStart, displayedComponents: .hourAndMinute, label: { Text("") })
                                    .datePickerStyle(FieldDatePickerStyle())
                                    .frame(width: 90, height: 38)
                                    .cornerRadius(7)
                                    .focusable()
                                
                                Text("and")

                                DatePicker(selection: $reminderEnd, displayedComponents: .hourAndMinute, label: { Text("") })
                                    .datePickerStyle(FieldDatePickerStyle())
                                    .frame(width: 90, height: 38)
                                    .cornerRadius(7)
                                    .focusable()
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .frame(minWidth: 200, maxWidth: .infinity, minHeight: 30, maxHeight:.infinity)
                    .padding()
                    .padding(.leading, 32)
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
        }
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
        
        print("Reseting...")
        
        if entries.count > 0 {
            print("1. Trying to delete entries...")
            
            for index in 0...entries.count-1 {
                moc.delete(entries[index])
            }
            
            do {
                if (moc.hasChanges) {
                    try moc.save()
                }
            } catch {
                // handle the Core Data error
            }
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
        }
        
        // Cancel any pending notifications
        
        print("3. Clearing notifications...")
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Close the settings window as confirmation
        
        print("4. Closing window")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApplication.shared.keyWindow?.close()
        }
    }
    
    func ScheduleNotifications() {
        let center = UNUserNotificationCenter.current()
        
        print("Attempting to schedule notifs...")
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                remindersEnabled = true
                
                // Create the content for notifications
                
                let content = UNMutableNotificationContent()
                content.title = "Time to log activity"
                content.body = "Use Dayand to log what you're doing now and your reaction to it."
                content.categoryIdentifier = "alarm"
                content.sound = UNNotificationSound.default
                
                // Scheduling random minutes between the times set by reminderStart and reminderEnd
                                
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
                                
                for index in 0...hoursbetween {
                    var randomMinute: Int
                    
                    // Generate the hour, twice so user gets at least two notifications every hour
                    
                    for _ in 1...2 {
                        randomMinute = Int.random(in: 1..<59)
                        
                        if index == 0 {
                            randomMinute = startMinute
                        }
                        
                        let tempInt = index * (60 * 60)
                        let tempComponents = Calendar.current.dateComponents([.hour], from: reminderStart.addingTimeInterval(TimeInterval(tempInt)))

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
            } else {
                Alert(title: Text("Notifications not enabled"), message: Text("Dayand does not have permission to enable notifications. Please check your system settings to continue."), dismissButton: .default(Text("Ok")))
                remindersEnabled = false
            }
        }
    }
    
    func SaveAllChanges() {
        UserDefaults.standard.set(remindersEnabled, forKey: "DayandRemindersEnabled")
        
        if !remindersEnabled {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else {
            UserDefaults.standard.set(reminderStart, forKey: "DayandReminderStartTime")
            UserDefaults.standard.set(reminderEnd, forKey: "DayandReminderEndTime")
            ScheduleNotifications()
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
