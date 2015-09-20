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
    
    var time:Int = 30
    var latitude = 0
    var longitude = 0
    
    //MARK: - Number Slider Code
    var sliderValue:Int = 30
    var maxVal:Int = 1440
    var minVal:Int = 30
    var increment:Int = 30
    
    var isRequestingLocation = false
    
    let requestURL = "http://172.20.10.3:8080/request"
    let manager = CLLocationManager()
    
    @IBOutlet weak var meterTimer: WKInterfaceTimer!
    @IBOutlet weak var startButton: WKInterfaceButton!
    
    @IBAction func meterSliderDidIncrease() {
        sliderValue = sliderValue + increment
        
        if sliderValue > maxVal {sliderValue = maxVal} //enforce upper boundary
        updateLabel()
    }
    
    @IBAction func meterSliderDidDecrease() {
        sliderValue = sliderValue - increment
        if sliderValue < minVal {sliderValue = minVal} //enforce lower boundary
        updateLabel()
    }
    
    func updateLabel(){
        self.time = sliderValue
        
        let interval: NSTimeInterval = Double((sliderValue + 1) * 60)
        meterTimer.setDate(NSDate(timeIntervalSinceNow: interval))
    }
    
    
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
        //TODO: Send Request Here
        let query = self.requestURL
        let url: NSURL = NSURL(string: query)!
        
        /** Worried about GPS Sensitivity at Pier 70. Will hard-code coordinates for presentation, just in case.
        let lat: Double = Double((self.location?.latitude)!)
        let long: Double = Double((self.location?.longitude)!)
        */
        
        let lat: Double = 37.7586
        let lon: Double = -122.3844

        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let params = ["customerId":"1", "lat":lat, "lon":lon, "minutes": self.time]
        
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(params, options: [])
        } catch {
            print(error)
            request.HTTPBody = nil
        }
        
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: config)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            if((error) != nil) {
                NSLog(error!.localizedDescription)
            } else {
                if data != nil {
                    if let csv = NSString(data: data!, encoding: NSUTF8StringEncoding ) {
                        NSLog("\(csv)")
                    }
                }
            }
        })
        task.resume()
        
        
        // do http request and if successful
        hasMeterTimer = true
        let latDegrees = CLLocationDegrees(lat)
        let lonDegrees = CLLocationDegrees(lon)
        let coordinates = CLLocationCoordinate2D(latitude: latDegrees, longitude: lonDegrees)
        let requestDTO: Request = Request(timeInMinutes: self.time, latitude: latDegrees, longitude: lonDegrees, coordinate: coordinates)
        
        
        
        WKInterfaceController.reloadRootControllersWithNames(["CurrentMeter"], contexts: [requestDTO])
    }
    
    
    /** Worried about GPS sensitivity at Pier 70. Will hard-code coordinates for presentation, just in case.
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
    */
}