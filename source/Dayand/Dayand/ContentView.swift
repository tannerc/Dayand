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
    @State private var hovered = false
    @Namespace var exampleNamespace
    
    @Environment(\.openURL) var openURL
    @Environment(\.managedObjectContext) var moc
    //var moc = NSManagedObjectContext.init(concurrencyType: .privateQueueConcurrencyType)
    
    @FetchRequest(entity: Dataobject.entity(),
                  sortDescriptors:
                    [NSSortDescriptor(keyPath: \Dataobject.date, ascending: true)],
                  predicate: NSPredicate(format: "date == \(GetTodaysDate())")
    ) var entries: FetchedResults<Dataobject>

    @State var entryString: String = ""
    @State private var entrySubmitted = false
    
    var winControl = NSWindowController.self
    var activityWindow = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 700, height: 625),
        styleMask: [.titled, .closable, .resizable],
        backing: .buffered, defer: false)
    var settingsWindow = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 700, height: 600),
        styleMask: [.titled, .closable],
        backing: .buffered, defer: false)
        
    static let entryDateFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }()
    
    // This is the response array, it can be customized to have fewer or more items, though maximum of five works best for the UI.
    
    let responseArr = ["😡", "☹️", "😐", "🙂", "😄"]
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                
                // Top header of the window pane, for today's date and app menu entry point
                
                HStack(alignment: .center) {
                    
                    // Display today's date. Feels redundant since this is a status bar app and the date is often displayed, but using anyway
                    
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
                            openURL(URL(string: "https://github.com/tannerc/Dayand")!)
                        }) {
                            Text("About Dayand \(GetBuildVersion())")
                        }
                        
                        // Button for supporting Tanner, the creator
                        
                        Button(action: {
                            openURL(URL(string: "https://ko-fi.com/tannerc")!)
                        }) {
                            Text("Support the creator")
                        }
                        
                        // Button for quitting the app
                        
                        Button(action: {
                            NSApplication.shared.terminate(self)
                        }) {
                            Text("Quit")
                        }
                    }
                    .background(Image("SettingsImage").resizable().frame(width: 24, height: 24, alignment: .center).foregroundColor(Color(.textColor)))
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
                    .background(Color(.textColor).opacity(hovered && !entrySubmitted ? 0.05 : 0.03))
                    .cornerRadius(7)
                    .disabled(entrySubmitted)
                    .onHover {_ in
                        self.hovered.toggle()
                    }
                
                /*
                 Here we're pulling from the responseArray to create a series of response buttons.
                 
                 Our response buttons are put into an HStack to create a clean layout that scales according to the number of responses listed in the responseDictionary.
                 
                 Buttons themselves are a bit janky due to SwiftUI issues, unfortunately.
                */
                
                HStack(alignment: .center, spacing: 0) {
                    
                    ForEach(Array(responseArr.enumerated()), id: \.offset) { index, response in
                        Button(action: {
                            LogEntry(response: (index+1))
                        }) {
                            Text(responseArr[index])
                                .font(.title)
                                .contentShape(Rectangle())
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color("backgroundColor"))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .frame(minWidth: 20, maxWidth: .infinity, minHeight: 20)
                    }
                }
                .padding(.horizontal, 40)
                
            }
            .padding(0)
            .frame(width: 400.0, height: 170.0, alignment: .top)
            .background(Color("backgroundColor"))
            
            // Show a confirmation message when an activity is logged
            
            if(entrySubmitted){
                VStack() {
                    Text("Saved!")
                        .font(.title)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("backgroundColor"))
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color(.textColor).opacity(0.4))
                .animation(.easeInOut(duration: 0.5))
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
    
    func LogEntry(response: Int) {
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
        fullTimeFormatter.dateFormat = "yyyyMMddHHmmss"
        let loggedTime = fullTimeFormatter.string(from: Date())
        
        print("Would log \(entryString) with response \(response) for \(loggedTime)")
        
        let entry = Dataobject(context: moc)
        entry.id = UUID()
        entry.date = Int32(logDate) ?? 0
        entry.time = Int32(logTime) ?? 0
        entry.logdate = Int64(loggedTime) ?? 0
        entry.response = Int32(response)
        if entryString.count > 0 {
            entry.activity = entryString
        }
        
        // Animate everything out, but do it carefully for reasons
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            NSApplication.shared.keyWindow?.close()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                entrySubmitted = false
                entryString = ""
            }
        }
    }
    
    // Get build version of the app to display in the settings menu

    func GetBuildVersion() -> String {
        if let text = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return(text)
        } else {
            return("")
        }
    }
    
    func SaveState() {
        if moc.hasChanges {
            moc.processPendingChanges()
            
            do {
                try moc.save()
            } catch {
                // Customize this code block to include application-specific recovery steps.
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }
    
    // Open settings view in a new window object

    func DisplaySettingsWindow() {
        
        SaveState()
        
        let contentView = SettingsView().environment(\.managedObjectContext, moc)

        // Create the window and set the content view.
        
        settingsWindow.center()
        settingsWindow.styleMask.remove(.resizable)
        settingsWindow.titlebarAppearsTransparent = true
        settingsWindow.styleMask.insert(.fullSizeContentView)
        settingsWindow.titleVisibility = .hidden
        settingsWindow.title = "Dayand Settings"
        settingsWindow.setFrameAutosaveName("Settings Window")
        settingsWindow.backgroundColor = NSColor(Color("backgroundColor"))
        settingsWindow.contentView = NSHostingView(rootView: contentView)
        settingsWindow.makeKeyAndOrderFront(settingsWindow.self)
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow.isReleasedWhenClosed = false
    }
    
    // Open activity view in a new window object

    func DisplayActivityWindow() {
        
        SaveState()
        
        let contentView = ActivityView().environment(\.managedObjectContext, moc)
            .frame(minWidth: 800, minHeight: 545)

        // Create the window and set the content view.
        
        activityWindow.center()
        activityWindow.titlebarAppearsTransparent = true
        activityWindow.styleMask.insert(.fullSizeContentView)
        activityWindow.setFrameAutosaveName("Activity Window")
        activityWindow.backgroundColor = NSColor(Color("backgroundColor"))
        activityWindow.contentView = NSHostingView(rootView: contentView)
        activityWindow.makeKeyAndOrderFront(activityWindow.self)
        activityWindow.minSize = NSSize(width: 800, height: 545)
        NSApp.activate(ignoringOtherApps: true)
        activityWindow.isReleasedWhenClosed = false
        
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
