//
//  InterfaceController.swift
//  MeterBeater WatchKit Extension
//
//  Created by Karen Ho on 9/19/15.
//  Copyright © 2015 Karen Ho. All rights reserved.
//

import WatchKit
import Foundation


var hasMeterTimer: Bool = false

class InterfaceController: WKInterfaceController {
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        // if logged in
        if (!hasMeterTimer) {
            WKInterfaceController.reloadRootControllersWithNames(["StartMeter"], contexts: nil)
        } else {
            WKInterfaceController.reloadRootControllersWithNames(["CurrentMeter"], contexts: nil)
        }
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
