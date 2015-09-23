//
//  CurrentMeterController.swift
//  MeterBeater
//
//  Created by Karen Ho on 9/19/15.
//  Copyright © 2015 Karen Ho. All rights reserved.
//

import Foundation
import WatchKit

class CurrentMeterController: WKInterfaceController {
    
    @IBOutlet weak var meterTimer: WKInterfaceTimer!
    @IBOutlet weak var map: WKInterfaceMap!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let request: Request = context as? Request {
            let interval: NSTimeInterval = Double(request.timeInMinutes*60)
            self.meterTimer.setDate(NSDate(timeIntervalSinceNow: interval))
            self.meterTimer.start()
            
            self.map.setRegion(MKCoordinateRegionMakeWithDistance(request.coordinate, 500, 500))
            //let coordinateSpan: MKCoordinateSpan = MKCoordinateSpanMake(1, 1)
            
            self.map.addAnnotation(request.coordinate, withPinColor: WKInterfaceMapPinColor.Red)
            //self.map.setRegion(MKCoordinateRegionMake(request.coordinate, coordinateSpan))
        }
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}