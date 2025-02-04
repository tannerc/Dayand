//
//  AppDelegate.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/23/21.
//

import Cocoa
import SwiftUI
import CoreData
import UserNotifications

@main
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var statusItem: NSStatusItem?
    var popover = NSPopover.init()
    var statusBar: StatusBarController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Create the SwiftUI view that provides the window contents.
        
        let contentView = ContentView().environment(\.managedObjectContext, persistentContainer.viewContext)
        
        popover.contentViewController = MainViewController()
        popover.contentSize = NSSize(width: 400, height: 170)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusBar = StatusBarController.init(popover)
        
        // Create notification classification for the app
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let show = UNNotificationAction(identifier: "show", title: "Open Dayand", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        center.setNotificationCategories([category])
        
        if (UserDefaults.standard.object(forKey: "DayandReminderStartTime") == nil) {
            UserDefaults.standard.set(Date(), forKey: "DayandReminderStartTime")
            UserDefaults.standard.set(Date(), forKey: "DayandReminderEndTime")
            UserDefaults.standard.set(2, forKey: "DayandReminderCadenceTime")
        }
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            // Customize this code block to include application-specific recovery steps.
            let nserror = error as NSError
            NSApplication.shared.presentError(nserror)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
                
        print("Clicked on notification!")
        
        statusBar?.togglePopover(sender: StatusBarController.self)
        
        completionHandler()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
        // Because the app is closing, we should cancel all notifications (if scheduled) so ghost notifs don't appear for the user
        
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Core Data stack

    var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Dayand")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving and Undo support

    func windowWillReturnUndoManager(window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return persistentContainer.viewContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        let context = persistentContainer.viewContext
        
        if !context.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !context.hasChanges {
            return .terminateNow
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError

            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == .alertSecondButtonReturn {
                return .terminateCancel
            }
        }
        
        // If we got here, it is time to quit.
        
        return .terminateNow
    }
}
