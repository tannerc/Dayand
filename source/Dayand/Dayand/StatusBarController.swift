//
//  StatusBarController.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/23/21.
//

import Foundation
import AppKit
import UserNotifications

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var clickMonitor: EventsController?
    
    init(_ popover: NSPopover) {
        self.popover = popover
        statusBar = NSStatusBar.init()
        
        // Creating a status bar item having a fixed length
        
        statusItem = statusBar.statusItem(withLength: 32.0)
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = #imageLiteral(resourceName: "icon")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
            
            statusBarButton.action = #selector(togglePopover(sender:))
            statusBarButton.target = self
        }
        
        clickMonitor = EventsController(mask: [.leftMouseDown, .rightMouseDown], handler: mouseEventHandler)
    }
        
    @objc func togglePopover(sender: AnyObject) {
        if(popover.isShown) {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { (notifications) in
            print("Count: \(notifications.count)")
        }
        
        if let statusBarButton = statusItem.button {
            
            // Create the popover position
            
            let positioningView = NSView(frame: statusBarButton.bounds)
            positioningView.identifier = NSUserInterfaceItemIdentifier(rawValue: "positioningView")
            statusBarButton.addSubview(positioningView)
            
            // Show the popover
            
            if self.statusItem.button != nil {
                if self.popover.isShown {
                    self.popover.performClose(sender)
                } else {
                    self.popover.show(relativeTo: positioningView.bounds, of: positioningView, preferredEdge: .maxY)
                    statusBarButton.bounds = statusBarButton.bounds.offsetBy(dx: 0, dy: statusBarButton.bounds.height)
                    
                    self.popover.contentViewController?.view.window?.becomeKey()
                    
                    if let popoverWindow = popover.contentViewController?.view.window {
                        popoverWindow.setFrame(popoverWindow.frame.offsetBy(dx: 0, dy: 10), display: false)
                    }
                }
            }
            
            clickMonitor?.start()
        }
    }
    
    func hidePopover(_ sender: AnyObject) {
        popover.performClose(sender)
        clickMonitor?.stop()
    }

    func mouseEventHandler(_ event: NSEvent?) {
        if(popover.isShown) {
            hidePopover(event!)
        }
    }
}
