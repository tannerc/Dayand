//
//  LogViewController.swift
//  Dayand
//
//  Created by Tanner Christensen on 1/23/21.
//

import Foundation
import AppKit

class LogViewCongtroller: NSViewController {
    override func viewDidAppear() {
        super.viewDidAppear()

        // You can use a notification and observe it in a view model where you want to fetch the data for your SwiftUI view every time the popover appears.
        // NotificationCenter.default.post(name: Notification.Name("ViewDidAppear"), object: nil)
    }
}
