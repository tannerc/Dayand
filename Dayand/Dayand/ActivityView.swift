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
    
    // Chart range is a sticky setting saved to UserDefaults
    
    @State private var daysToChart = UserDefaults.standard.integer(forKey: "DayandChartRange")
    @State private var scrollTarget: Int? = 0
    
    init() {
        if (UserDefaults.standard.integer(forKey: "DayandChartRange") == 0) {
            UserDefaults.standard.set(7, forKey: "DayandChartRange")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let fromDate = dateFormatter.string(from: Date())
        let toDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: (90 * -1), to: Date()) ?? Date())
        
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
            
            HStack() {
                Spacer()
                
                // SwiftUI is a bit weird with MenuButtons, to create an appropriate label for our button we put it into a ZStack with a Text label.
                
                ZStack(alignment: .leading) {
                    MenuButton("") {
                        Button(action: {ChangeChartRange(to: 7)}, label: {
                            Text("7 days")
                        })

                        Button(action: {ChangeChartRange(to: 14)}, label: {
                            Text("14 days")
                        })

                        Button(action: {ChangeChartRange(to: 31)}, label: {
                            Text("31 days")
                        })
                    }
                    .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                    .frame(width: 132, height: 38, alignment: .trailing)
                    .background(Image("DownTriangleImage").resizable().frame(width: 24, height: 24).foregroundColor(Color(.textColor)).scaleEffect(0.9).padding(8), alignment: .trailing)
                    .background(Color(.highlightColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(Color(.systemGray).opacity(0.4), lineWidth: 1)
                    )
                    .cornerRadius(9)
                    .shadow(color: Color(.shadowColor).opacity(0.2), radius: 1, x: 0, y: 1)

                    Text("Chart \(daysToChart) Days")
                        .font(.headline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.leading, 11.0)
                        .allowsHitTesting(false)
//                        .padding(.horizontal, 24.0)
                }
                
                // Export to PDF button
                
                CustomButtonView(title: "Export CSV", action: { NSApplication.shared.keyWindow?.close() }, disabledState: false, buttonClass: "Default")
                    .padding(.trailing, 10)
            }
            .padding(.bottom, 4)
                
            // Chart view will go here
            
            ChartNEntries()
            
            // List view of all past data
            
            HStack(alignment: .top) {
                ScrollView() {
                    ScrollViewReader { proxy in
                        VStack(alignment: .leading) {
                            ForEach(entries, id: \.self) { (loggedentry: Dataobject) in
                                HStack(alignment: .top) {
                                    Text(ConvertLogDate(thedate: loggedentry.logdate))
                                        .font(.headline)
                                    Text(loggedentry.message ?? "No message")
                                    Text(String(loggedentry.response))
                                    Text(String(entries.firstIndex(of: loggedentry) ?? 0))
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .id(entries.firstIndex(of: loggedentry) ?? 0)
                                .padding()
                            }
                        }
                        .onChange(of: scrollTarget) { target in
                            if let target = target {
                                
                                NSLog("Total scrollable area: \(entries.count - 1)")
                                
                                if (scrollTarget ?? 0 >= entries.count) {
                                    scrollTarget = entries.count - 1
                                }
                                
//                                scrollTarget = nil
                                print("SCROLL TARGET IS: \(scrollTarget)")

                                withAnimation {
                                    proxy.scrollTo(target, anchor: .top)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 12)
            .listRowBackground(Color(.highlightColor))
            
            Spacer()
        }
        .padding(.top, 20)
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
    
    func ChangeChartRange(to: Int) {
        daysToChart = to
        UserDefaults.standard.set(to, forKey: "DayandChartRange")
    }
    
    func ChartNEntries() -> ChartUIView {
        
        // Update lastndaysArray to contain last "daysToChart" days
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        var lastndaysArray = [String: Int32]()
        
        for index in 0...(daysToChart-1) {
            let toDate = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: (index * -1), to: Date()) ?? Date())
            lastndaysArray[toDate] = 0
        }
        
//        print("Starting lastndaysArray for \(daysToChart) days (lastndays is: \(lastndays.count)): \(lastndaysArray)")
        
        let sortedArrayKeys = Array(lastndaysArray.keys.sorted(by: <))
        
        for index in 0...(daysToChart-1) {
            if (lastndays.count > index) {
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
                        
                        let themath = (existingAvg + indexAvg)
                        newAvg = (themath / 2)
                    }
                    
                    lastndaysArray[String(lastndays[index].date)] = Int32(newAvg)
                } else {
                    
                    // No day logged within time range, report zero
                                        
                    lastndaysArray[String(lastndays[index].date)] = 0
                }
            }
        }
        
        return ChartUIView(chartdata: lastndaysArray, scrollTarget: self.$scrollTarget)
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView().environment(\.colorScheme, .light)
    }
}
