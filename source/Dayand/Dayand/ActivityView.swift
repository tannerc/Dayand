//
//  ActivityView.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/25/21.
//

import Foundation
import SwiftUI
import CoreData

struct ActivityView: View {
    
    @Environment(\.managedObjectContext) var moc
    
    // Fetch all objects
    
    @FetchRequest(entity: Dataobject.entity(),
                  sortDescriptors:
                    [NSSortDescriptor(keyPath: \Dataobject.logdate, ascending: false)]
    ) var entries: FetchedResults<Dataobject>
    
    // Fetch the last n days
    
    @FetchRequest var lastndays: FetchedResults<Dataobject>
    
    // Chart range is a sticky setting saved to UserDefaults
    
    @State private var daysToChart = UserDefaults.standard.integer(forKey: "DayandChartRange")
    
    // Scroll for activity log set to zero to start
    
    @State private var scrollTarget: Int? = 0
    
    // Init for daterange filtering between toDate and fromDate
    
    init() {
        if (UserDefaults.standard.integer(forKey: "DayandChartRange") == 0) {
            UserDefaults.standard.set(7, forKey: "DayandChartRange")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let fromDate = dateFormatter.string(from: Date())
        let toDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: (1200 * -1), to: Date()) ?? Date())
                
        var predicate: NSPredicate?
        predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", toDate, fromDate)
        
        self._lastndays = FetchRequest(
            entity: Dataobject.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Dataobject.logdate, ascending: false)],
            predicate: predicate)
    }
    
    var lastndaysArray = [String: Int]()
    @State private var rowHovered = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Window header
            
            HStack() {
                Text("Activity Log")
                    .font(.largeTitle)
                    .padding(.leading, 20)
                
                Spacer()
                
                // SwiftUI is a bit weird with MenuButtons, to create an appropriate label for our button we put it into a ZStack with a Text label.
                
                ZStack(alignment: .leading) {
                    MenuButton("") {
                        Button(action: {ChangeChartRange(to: 1)}, label: {
                            Text("Today")
                        })
                        
                        Button(action: {ChangeChartRange(to: 7)}, label: {
                            Text("Last 7 days")
                        })

                        Button(action: {ChangeChartRange(to: 14)}, label: {
                            Text("Last 14 days")
                        })

                        Button(action: {ChangeChartRange(to: 31)}, label: {
                            Text("Last 31 days")
                        })
                        
                        Button(action: {ChangeChartRange(to: 48)}, label: {
                            Text("Last 48 days")
                        })
                        
                        Button(action: {ChangeChartRange(to: 90)}, label: {
                            Text("Last 90 days")
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

                    Text(daysToChart == 1 ? "Today" : "Last \(daysToChart) days")
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.leading, 11.0)
                        .allowsHitTesting(false)
                }
                
                // Export to PDF button
                
                CustomButtonView(title: "Export CSV", action: { ExportToPDF() }, disabledState: false, buttonClass: "Default")
                    .padding(.trailing, 20)
                    .disabled(entries.count > 0 ? false : true)
            }
            .padding(.bottom, 4)
            .padding(.top, -12)
                
            // Chart view
            
            ChartNEntries()
            
            // List view of all past data
            // Starting with a table header
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text("Date")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 120, minHeight: 30, alignment: .leading)
                    
                    Text("Time")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 80, minHeight: 30, alignment: .leading)
                    
                    Text("Response")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .frame(minWidth: 80, minHeight: 30, alignment: .leading)
                    
                    Text("Activity")
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: 40)
//                .background(Color(.textColor).opacity(0.02))
                
//                Divider().background((Color(.lightGray)).opacity(0.02))
                
                // Now all the data in a table-like format
                
                ScrollView() {
                    ScrollViewReader { proxy in
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(entries, id: \.self) { (loggedentry: Dataobject) in
                                TableRow(withDate: loggedentry.logdate, withResponse: loggedentry.response, withActivity: loggedentry.activity ?? "No activity", theObject: loggedentry)
                                    .id(entries.firstIndex(of: loggedentry) ?? 0)
                                Divider().background((Color(.lightGray)).opacity(0.02))
                            }
                        }
                        .onChange(of: scrollTarget) { target in
                                                        
                            // Detects if scrollTarget variable has been changed from the ChartUIView
                            // If scrollTarget has been changed, scrolls to the appropriate location within the ScrollViewReader
                            
                            if let target = target {
                                if (scrollTarget ?? 0 >= entries.count) {
                                    scrollTarget = entries.count - 1
                                }

                                withAnimation {
                                    proxy.scrollTo(target, anchor: .top)
                                }
                            }
                        }
                    }
                }
//                .overlay(
//                    RoundedRectangle(cornerRadius: 7)
//                        .stroke(Color(.systemGray).opacity(0.5), lineWidth: 1)
//                )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(Color(.systemGray).opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(7)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(20)
            .listRowBackground(Color("backgroundColor"))
            
            Spacer()
        }
        .padding(.top, 20)
    }
    
    // Function to get all saved activities
    
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
    
    // Simple function for changing the charted range of activities
    
    func ChangeChartRange(to: Int) {
        daysToChart = to
        UserDefaults.standard.set(to, forKey: "DayandChartRange")
    }
    
    // Function for getting the last n days of activity for visualizing
    
    func ChartNEntries() -> ChartUIView {
        
        // Update lastndaysArray to contain last "daysToChart" days
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        var lastNEntriesArray = [String: Int32]()
        
        for _ in 0...300 {
            let day = arc4random_uniform(UInt32(91))+1
            let hour = arc4random_uniform(23)
            let minute = arc4random_uniform(59)

            let today = Date(timeIntervalSinceNow: 0)
            let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
            var offsetComponents = DateComponents()
            offsetComponents.day = -1 * Int(day - 1)
            offsetComponents.hour = -1 * Int(hour)
            offsetComponents.minute = -1 * Int(minute)

            let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) ) ?? Date()
            let toDate = dateFormatter.string(from: randomDate)
            print("Date is \(randomDate)")

            lastNEntriesArray[String(toDate)] = Int32(Int(Int.random(in: 1..<6)))
        }
        
//        if daysToChart < 1 {
//            daysToChart = 7
//        }
//
//        if (daysToChart == 1) {
//            let toDate = dateFormatter.string(from: Date())
//            lastNEntriesArray[toDate] = 0
//        } else {
//            for index in 0...(daysToChart) {
//                let toDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: (index * -1), to: Date()) ?? Date())
//                lastNEntriesArray[toDate] = 0
//            }
//        }
//
//        let sortedArrayKeys = Array(lastNEntriesArray.keys.sorted(by: <))
//
//        if (daysToChart == 1) {
//
//            // Charting today only
//
//            for indexnew in 0...(lastndays.count-1) {
//                if(sortedArrayKeys.contains(String(lastndays[indexnew].date))){
//                    lastNEntriesArray[String("\([lastndays.count-indexnew])")] = Int32(lastndays[indexnew].response)
//                }
//            }
//        } else {
//            for index in 0...(daysToChart) {
//                if (lastndays.count > index) {
//                    if(sortedArrayKeys.contains(String(lastndays[index].date))){
//
//                        // Logged day is within the time range to chart
//                        // Get the response and set it as an average...
//
//                        let existingAvg = lastNEntriesArray[String(lastndays[index].date)] ?? 0
//                        let indexAvg = lastndays[index].response
//                        var newAvg = Int32(0)
//
//                        if existingAvg == 0 {
//
//                            // No existing average for the date, set the new average to this index to start calculating (if there are multiple inputs for a single day)
//
//                            newAvg = Int32(Int(indexAvg))
//                        } else {
//
//                            // Existing average greater than zero, do some math
//
//                            let themath = (existingAvg + indexAvg)
//                            newAvg = (themath / 2)
//                        }
//
//                        lastNEntriesArray[String(lastndays[index].date)] = Int32(newAvg)
//
//                    } else {
//
//                        // No day logged within time range, report zero
//
//                        lastNEntriesArray[String(lastndays[index].date)] = 0
//                    }
//                }
//            }
//        }
                
        return ChartUIView(chartdata: lastNEntriesArray, scrollTarget: self.$scrollTarget)
    }
    
    // Export to PDF... of course
    
    func ExportToPDF() {
        let panel = NSSavePanel()
        panel.nameFieldLabel = "Save activity PDF as:"
        panel.nameFieldStringValue = "Dayand activity log.csv"
        panel.canCreateDirectories = true
        panel.begin { response in
            if response == NSApplication.ModalResponse.OK, let fileUrl = panel.url {
                var str = "Date,Time,Activity,Response\n"
                
                for loggedentry in entries {
                    str.append("\(loggedentry.date),\(loggedentry.time),\(loggedentry.activity?.escapeString() ?? ""),\(loggedentry.response)\n")
                }

                do {
                    try str.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
                } catch {
                    // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
                }
            }
        }
    }
}

// Escape extension for ensuring when saving data to CSV commas are escaped from activities the user may have input

extension String {
    func escapeString() -> String {
        var newString = self.replacingOccurrences(of: "\"", with: "\"\"")
        if newString.contains(",") || newString.contains("\n") {
            newString = String(format: "\"%@\"", newString)
        }

        return newString
    }
}

// Structure for table rows and relevant actions (like deleting a saved activity)

struct TableRow: View {
    
    @Environment(\.managedObjectContext) var moc
    
    @State var hovered = false
    var withDate: Int64
    var withResponse: Int32
    var withActivity: String
    var theObject: Dataobject
    
    let responseArr = ["😡", "☹️", "😐", "🙂", "😄"]
    
    var body: some View {
        HStack(spacing: 0) {
            Text(ConvertLogDate(thedate: withDate))
                .multilineTextAlignment(.leading)
                .frame(minWidth: 120, minHeight: 30, alignment: .leading)
            
            Text(ConvertLogTime(thetime: withDate))
                .multilineTextAlignment(.leading)
                .frame(minWidth: 80, minHeight: 30, alignment: .leading)
            
            Text(responseArr[Int(withResponse-1)])
                .multilineTextAlignment(.center)
                .frame(minWidth: 80, minHeight: 30, alignment: .center)
            
            Text(withActivity)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            
            MenuButton("") {
//                Button(action: {
//                    updateActivity(activity: theObject)
//                }) {
//                    Text("Edit activity")
//                }
                
                Button(action: {
                    removeActivity(activity: theObject)
                }) {
                    Text("Delete activity")
                }
            }
            .contentShape(Rectangle())
            .menuButtonStyle(BorderlessButtonMenuButtonStyle())
            .frame(width: 32, height: 32, alignment: .center)
            .background(Image("OverflowIconImage").resizable().frame(width: 26, height: 26).foregroundColor(Color(.textColor).opacity(0.8)).padding(8), alignment: .center)
            .opacity(self.hovered ? 1.0 : 0)
            .disabled(self.hovered ? false : true)
            
            Spacer()
        }
        .padding()
        .background(Color(.textColor).opacity(self.hovered ? 0.01 : 0))
        .onHover {_ in self.hovered.toggle() }
    }
    
    // Useful function for converting the date of our data
    
    func ConvertLogDate(thedate: Int64) -> String {
        let dateString = String(thedate)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.locale = Locale.init(identifier: "en_US")
        
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        let returnstring = dateFormatter.string(from: dateObj!)
        
        return returnstring
    }
    
    // Lazy duplicate of previous function for converting time of our data
    
    func ConvertLogTime(thetime: Int64) -> String {
        let dateString = String(thetime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        dateFormatter.locale = Locale.init(identifier: "en_US")
        
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let returnstring = dateFormatter.string(from: dateObj!)
        
        return returnstring
    }
    
    // Function for editing an activity object from the Managed Object Context
    
    func updateActivity(activity: Dataobject) {
        
        // Never got around to actually creating a UI for updating activities, so punting this for a future release
        
    }
    
    // Function for removing an activity object from the Managed Object Context, which we duplicated at the top of this structure
    
    func removeActivity(activity: Dataobject) {
        moc.delete(activity)
        if (moc.hasChanges) {
            do {
                try moc.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
