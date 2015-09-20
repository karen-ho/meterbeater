//
//  StartMeterController.swift
//  MeterBeater
//
//  Created by Karen Ho on 9/19/15.
//  Copyright © 2015 Karen Ho. All rights reserved.
//

import WatchKit
import Foundation

class StartMeterController: WKInterfaceController, CLLocationManagerDelegate {
    
    var time: Float = 30
    var latitude = 0
    var longitude = 0
    
    var isRequestingLocation = false
    let manager = CLLocationManager()
    
    @IBOutlet weak var meterTimer: WKInterfaceTimer!
    @IBOutlet weak var meterSlider: WKInterfaceSlider!
    @IBOutlet weak var startButton: WKInterfaceButton!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        // Configure interface objects here.
        
        manager.delegate = self
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        meterTimer.setDate(NSDate(timeIntervalSinceNow: 31*60))
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func startMeter() {
        guard !isRequestingLocation else {
            manager.stopUpdatingLocation()
            isRequestingLocation = false
            return
        }
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .NotDetermined:
            isRequestingLocation = true
            startButton.setTitle("Finding Location...")
            manager.requestWhenInUseAuthorization()
        case .AuthorizedWhenInUse:
            isRequestingLocation = true
            startButton.setTitle("Finding Location...")
            manager.requestLocation()
        case .Denied:
            NSLog("Denied")
        default:
            NSLog("Some undermined status")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty else { return }
        
        dispatch_async(dispatch_get_main_queue()) {
            let lastLocationCoordinate = locations.last!.coordinate
            
            NSLog("starting meter with \(self.time) \(lastLocationCoordinate.latitude) \(lastLocationCoordinate.longitude)")
            
            let request: Request = Request(timeInMinutes: self.time, latitude: lastLocationCoordinate.latitude, longitude: lastLocationCoordinate.longitude, coordinate: lastLocationCoordinate)
            
            self.isRequestingLocation = false
            
            // do http request and if successful
            hasMeterTimer = true
            
            
            WKInterfaceController.reloadRootControllersWithNames(["CurrentMeter"], contexts: [request])
        }
    }
    
    /**
    When the location manager receives an error, display the error and restart
    the timers.
    */
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        dispatch_async(dispatch_get_main_queue()) {
            self.isRequestingLocation = false
        }
    }
    
    /**
    Only request location if the authorization status changed to an
    authorization level that permits requesting location.
    */
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        dispatch_async(dispatch_get_main_queue()) {
            guard self.isRequestingLocation else { return }
            
            switch status {
            case .AuthorizedWhenInUse:
                manager.requestLocation()
                
            case .Denied:
                self.isRequestingLocation = false
                
            default:
                self.isRequestingLocation = false
            }
        }
    }
    
    @IBAction func sliderAction(value: Float) {
        self.time = value - 1
        
        let interval: NSTimeInterval = Double(value*60)
        meterTimer.setDate(NSDate(timeIntervalSinceNow: interval))
    }
}