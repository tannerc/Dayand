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
    
    // Fetch all objects
    
    @FetchRequest(entity: Dataobject.entity(),
                  sortDescriptors:
                    [NSSortDescriptor(keyPath: \Dataobject.logdate, ascending: false)]
    ) var entries: FetchedResults<Dataobject>
    
    // Fetch the last n days
    
    @FetchRequest var lastndays: FetchedResults<Dataobject>
    var daysToChart = 7
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let fromDate = dateFormatter.string(from: Date())
        let toDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: (daysToChart * -1), to: Date()) ?? Date())
        
        print("Would look for dates between \(toDate) and \(fromDate)")
        
        var predicate: NSPredicate?
        predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", toDate, fromDate)

        self._lastndays = FetchRequest(
        entity: Dataobject.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Dataobject.logdate, ascending: false)],
        predicate: predicate)
    }
    
    var lastndaysArray = [String: Int]()
    
    // For checking responses
    
    let responseDic = ["😡" : "0",
                       "☹️" : "1",
                       "😐" : "2",
                       "🙂" : "3",
                       "😄" : "4",
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Chart view will go here
            
            ParseLastNEntries()
            
            // List view of all past data
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    List {
                        ForEach(entries, id: \.self) { (loggedentry: Dataobject) in
                            HStack {
                                Text(ConvertLogDate(thedate: loggedentry.logdate))
                                    .font(.headline)
                                Text(loggedentry.message ?? "No message")
                                Text(String(loggedentry.response))
                            }.padding()
                        }.listRowBackground(Color.clear)
                    }.listRowBackground(Color.clear)

                    Spacer()
                }
            }
            .padding(.bottom, 12)
            
            // Controls
            
            Spacer()
        }.padding(.top, 20)
    }
    
    func ConvertLogDate(thedate: Int64) -> String {
        let dateString = String(thedate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        dateFormatter.locale = Locale.init(identifier: "en_US")
        
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
//        dateFormatter.dateFormat = "MMM dd-yyyy"
        let returnstring = dateFormatter.string(from: dateObj!)
        
        return returnstring
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
    
    func ParseLastNEntries() -> ChartUIView {
        
        // Update lastndaysArray to contain last "daysToChart" days
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        var lastndaysArray = [String: Int32]()
        
        for index in 0...(daysToChart - 1) {
            let toDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: (index * -1), to: Date()) ?? Date())
            lastndaysArray[toDate] = 0
        }
        
        print("Starting lastndaysArray: \(lastndaysArray)")
        
        let sortedArrayKeys = Array(lastndaysArray.keys.sorted(by: <))
        
        for index in 0...(lastndays.count-1) {
            print("Checking \(lastndays[index].date)...")
            
            if(sortedArrayKeys.contains(String(lastndays[index].date))){
                
                // Logged day is within the time range to chart
                // Get the response and set it as an average...
                
                let existingAvg = lastndaysArray[String(lastndays[index].date)] ?? 0
                let indexAvg = lastndays[index].response
                var newAvg = Int32(0)
                
                if existingAvg == 0 {
                    
                    // No existing average for the date, set the new average to this index to start calculating (if there are multiple inputs for a single day)
                    
                    newAvg = Int32(Int(indexAvg))
                } else {
                    
                    // Existing average greater than zero, do some math
                    
                    print("Avg exists! Math: \(existingAvg) + \(indexAvg) / 2")
                    
                    let themath = (existingAvg + indexAvg)
                    print("The math: \(Int32(themath))")
                    newAvg = (themath / 2)
                }
                
                print("New avg for this date: \(Int32(newAvg))")
                lastndaysArray[String(lastndays[index].date)] = Int32(newAvg)
            } else {
                
                // No day logged within time range, report zero
                
                print("Day not in range, setting average to zero")
                
                lastndaysArray[String(lastndays[index].date)] = 0
            }
        }
        
        print(lastndaysArray.sorted(by: <))
        
        return ChartUIView(chartdata: lastndaysArray)
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
