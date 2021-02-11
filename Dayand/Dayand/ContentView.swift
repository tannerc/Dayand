//
//  ContentView.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/23/21.
//

import SwiftUI
import AppKit
import CoreData

struct ContentView: View {
    @Environment(\.openURL) var openURL
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: Dataobject.entity(),
                  sortDescriptors:
                    [NSSortDescriptor(keyPath: \Dataobject.date, ascending: true)],
                  predicate: NSPredicate(format: "date == \(GetTodaysDate())")
    ) var entries: FetchedResults<Dataobject>

    @State var entryString: String = ""
    @State private var entrySubmitted = false
        
    static let entryDateFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }()
    
    // This is the response dictionary, it can be customized to have fewer or more items, each should map to an int value for analytics.
    
    let responseDic = ["😡" : "1",
                       "☹️" : "2",
                       "😐" : "3",
                       "🙂" : "4",
                       "😄" : "5",
    ]
    
    var body: some View {
        
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                
                // Top header of the window pane, for today's date and app menu entry point.
                
                HStack(alignment: .center) {
                    
                    // Display today's date. Feels redundant since this is a status bar app and the date is often displayed?
                    
                    Text(ContentView.entryDateFormat.string(from: Date()) + " · " + GetTodaysEntries())
                        .font(.callout)
                        .fontWeight(.regular)
                        .foregroundColor(Color(.textColor))
                    
                    Spacer()
                    
                    // App menu button and items.
                    
                    MenuButton("") {
                        
                        // Button for opening the reporting view
                        
                        Button(action: {
                            DisplayActivityWindow()
                        }) {
                            Text("View Activity Log")
                        }
                        
                        // Button for opening the settings view
                        
                        Button(action: {
                            DisplaySettingsWindow()
                        }) {
                            Text("Settings")
                        }
                        
                        // Button for accessing the Github repo
                        
                        Button(action: {
                            openURL(URL(string: "https://github.com/tannerc/spf")!)
                        }) {
                            Text("About Dayand \(GetBuildVersion())")
                        }
                        
                        // Button for quitting the app
                        
                        Button(action: {
                            NSApplication.shared.terminate(self)
                        }) {
                            Text("Quit")
                        }
                    }.background(Image("SettingsImage").foregroundColor(Color(.textColor)).scaleEffect(0.9))
                        .frame(width: 24, height: 24, alignment: .trailing)
                        .padding(4)
                        .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                
                // Text input field. Needs to be revamped into something else to create a larger hit target and firstResponder.
                
                TextField("Enter activity then select a response", text: $entryString)
                    .font(.title2)
                    .textFieldStyle(PlainTextFieldStyle())
                    .contentShape(Rectangle())
                    .frame(width: 330, height: 20)
                    .padding(20)
                    .font(.body)
                    .foregroundColor(Color(.textColor))
                    .background(Color(.textColor).opacity(0.04))
                    .cornerRadius(6)
                    .disabled(entrySubmitted)
                
                
                /*
                 Here we're pulling from the responseDictionary to create a series of response buttons.
                 
                 Our response buttons are put into an HStack to create a clean layout that scales according to the number of responses listed in the responseDictionary.
                 
                 Buttons themselves are a bit janky due to SwiftUI issues, unfortunately.
                */
                
                HStack(alignment: .center, spacing: 0) {
                    
                    ForEach(responseDic.sorted(by: { $0.value < $1.value }), id: \.key) { key, value in
                        Button(action: {
                            LogEntry(textEntry: entryString, response: Int(value) ?? 0)
                        }) {
                            Text(key)
                                .font(.title)
                                .contentShape(Rectangle())
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color(.windowBackgroundColor))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20)
                    }
                }
                .padding(.horizontal, 40)
                
            }
            .padding(0)
            .frame(width: 400.0, height: 170.0, alignment: .top)
            .background(Color(.windowBackgroundColor))
            
            if(entrySubmitted){
                VStack() {
                    Text("Saved!")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(.highlightColor))
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color(.textColor).opacity(0.5))
                .animation(.easeInOut(duration: 1.3))
                .scaleEffect()
            }
        }
        .frame(width: 400.0, height: 170.0, alignment: .top)
    }
    
    func GetTodaysEntries() -> String {
        
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
    
    // Function to log the entry and response.
    
    func LogEntry(textEntry: String, response: Int) {
        entrySubmitted = true
        
        // Format date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let logDate = dateFormatter.string(from: Date())
        
        // Get separate formatter for time of day
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hhmm"
        let logTime = timeFormatter.string(from: Date())
        
        // Seconds don't display in the UI, but they are logged for reporting and sorting purposes
        
        let fullTimeFormatter = DateFormatter()
        fullTimeFormatter.dateFormat = "yyyyMMddhhmmss"
        let loggedTime = fullTimeFormatter.string(from: Date())
        
        
        print("Would log \(textEntry) with response \(response) for \(loggedTime)")
        entryString = ""
        
        let entry = Dataobject(context: self.moc)
        entry.id = UUID()
        entry.date = Int32(logDate) ?? 0
        entry.time = Int32(logTime) ?? 0
        entry.logdate = Int64(loggedTime) ?? 0
        entry.response = Int32(response)
        entry.message = textEntry
        try? self.moc.save()
        
        // Animate everything out, but do it carefully for reasons
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            NSApplication.shared.keyWindow?.close()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                entrySubmitted = false
            }
        }
        
        print(entries)
    }
    
    // Get build version of the app to display in the settings menu

    func GetBuildVersion() -> String {
        if let text = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return(text)
        } else {
            return("")
        }
    }
    
    // Open settings view in a new window object

    func DisplaySettingsWindow() {
        var window: NSWindow!
        let contentView = SettingsView().environment(\.managedObjectContext, moc)

        // Create the window and set the content view.
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 600),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.center()
        window.styleMask.remove(.resizable)
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.titleVisibility = .hidden
        window.title = "Dayand Settings"
        window.setFrameAutosaveName("Settings Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(window.self)
        NSApp.activate(ignoringOtherApps: true)
        window.isReleasedWhenClosed = false
    }
    
    // Open activity view in a new window object

    func DisplayActivityWindow() {
        var window: NSWindow!
        let contentView = ActivityView().environment(\.managedObjectContext, moc)

        // Create the window and set the content view.
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 625),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.center()
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)
        window.title = "Activity Log"
        window.setFrameAutosaveName("Activity Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(window.self)
        NSApp.activate(ignoringOtherApps: true)
        window.isReleasedWhenClosed = false
    }
}

func GetTodaysDate() -> Int32 {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    let logDate = dateFormatter.string(from: Date())
    
    return Int32(logDate) ?? 00000000
}

// Override TextField ring focus since it's ugly

extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get { .none }
        set { }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.colorScheme, .light)
    }
}
