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
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @FetchRequest(entity: EntryObject.entity(), sortDescriptors: []) var entryObjects: FetchedResults<EntryObject>

    @State var entryString: String = ""
    @State private var entrySubmitted = false
        
    static let entryDateFormat: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter
        }()
    
    var body: some View {
        
        VStack {
            List {
                ForEach(entryObjects, id: \.id) { (entryObject: EntryObject) in
                    Text(entryObject.message ?? "Unknown")
                }
            }
        }
        
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                
                // Top header of the window pane, for today's date and app menu entry point.
                
                HStack(alignment: .center) {
                    
                    // Display today's date. Feels redundant since this is a status bar app and the date is often displayed?
                    
                    Text(ContentView.entryDateFormat.string(from: Date()))
                        .font(.callout)
                        .fontWeight(.regular)
                        .foregroundColor(Color(.secondaryLabelColor))
                    
                    Spacer()
                    
                    // App menu button and items.
                    
                    MenuButton("") {
                        
                        // Button for opening the reporting view
                        
                        Button(action: {
                            DisplaySettingsWindow()
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
                    }.background(Image("SettingsImage").foregroundColor(Color(.secondaryLabelColor)).scaleEffect(0.9))
                        .frame(width: 24, height: 24, alignment: .trailing)
                        .padding(4)
                        .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                
                // Text input field. Needs to be revamped into something else to create a larger hit target and firstResponder.
                
                TextField("What are you doing?", text: $entryString)
                    .font(.title2)
                    .textFieldStyle(PlainTextFieldStyle())
                    .contentShape(Rectangle())
                    .frame(width: 330, height: 20)
                    .padding(20)
                    .font(.body)
                    .foregroundColor(Color(.headerTextColor))
                    .background(Color(.separatorColor))
                    .cornerRadius(12)
                    .disabled(entrySubmitted)
                
                
                // Our "response" buttons are put into an HStack to create a clean layout.
                // Buttons themselves are a bit janky due to SwiftUI issues, unfortunately.
                // You can remove or add buttons and the remaining items will scale, mostly.
                
                HStack(alignment: .center, spacing: 0) {
                    Button(action: {
                        LogEntry(textEntry: entryString, response: 0)
                    }) {
                        Text("😡")
                            .font(.title)
                            .contentShape(Rectangle())
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color(.controlBackgroundColor))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20)
                    
                    Button(action: {
                        LogEntry(textEntry: entryString, response: 1)
                    }) {
                        Text("🙁")
                            .font(.title)
                            .contentShape(Rectangle())
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color(.controlBackgroundColor))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20)
                    
                    Button(action: {
                        LogEntry(textEntry: entryString, response: 2)
                    }) {
                        Text("😕")
                            .font(.title)
                            .contentShape(Rectangle())
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color(.controlBackgroundColor))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20)
                    
                    Button(action: {
                        LogEntry(textEntry: entryString, response: 3)
                    }) {
                        Text("🙂")
                            .font(.title)
                            .contentShape(Rectangle())
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color(.controlBackgroundColor))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20)
                    
                    Button(action: {
                        LogEntry(textEntry: entryString, response: 4)
                    }) {
                        Text("😄")
                            .font(.title)
                            .contentShape(Rectangle())
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color(.controlBackgroundColor))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 20)
                }
                .padding(.horizontal, 20)
            }
            .padding(0)
            .frame(width: 400.0, height: 170.0, alignment: .top)
            .background(Color(.controlBackgroundColor))
            
            if(entrySubmitted){
                VStack() {
                    Text("Saved!")
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(.windowBackgroundColor))
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color(.textColor).opacity(0.7))
                .animation(.easeInOut(duration: 2))
                .scaleEffect()
            }
        }
        .frame(width: 400.0, height: 170.0, alignment: .top)
    }
    
    // Function to log the entry and response.
    
    func LogEntry(textEntry: String, response: Int) {
        entrySubmitted = true
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let logDate = dateFormatter.string(from: Date())
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hhmm"
        let logTime = timeFormatter.string(from: Date())
        
        print("Would log \(textEntry) with response \(response) for \(logDate) \(logTime)")
        entryString = ""
        
        let entry = EntryObject(context: self.managedObjectContext)
        entry.id = UUID()
        entry.date = Int16(logDate) ?? 0
        entry.time = Int16(logTime) ?? 0
        entry.response = Int16(response)
        entry.message = textEntry
        try? self.managedObjectContext.save()
        
        // Animate everything out, but do it carefully for reasons
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            NSApplication.shared.keyWindow?.close()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                entrySubmitted = false
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
}

// Open settings view in a new window object

func DisplaySettingsWindow() {
    var window: NSWindow!
    let contentView = SettingsView()

    // Create the window and set the content view.
    
    window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 300, height: 600),
        styleMask: [.titled, .closable],
        backing: .buffered, defer: false)
    window.center()
    window.title = "Dayand Settings"
    window.setFrameAutosaveName("Main Window")
    window.contentView = NSHostingView(rootView: contentView)
    window.makeKeyAndOrderFront(window.self)
    window.isReleasedWhenClosed = false
    window.backgroundColor = .white
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
