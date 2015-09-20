//
//  ViewController.swift
//  MeterBeater
//
//  Created by Karen Ho on 9/19/15.
//  Copyright © 2015 Karen Ho. All rights reserved.
//

import UIKit
import WatchConnectivity
import CoreLocation
import MapKit

class ViewController: UIViewController, WCSessionDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    
    let locationManager = CLLocationManager()
    
    /// Default WatchConnectivity session for communicating with the watch.
    let session = WCSession.defaultSession()
    
    /// Location manager used to start and stop updating location.
    let manager = CLLocationManager()
    
    /// Indicates whether the location manager is updating location.
    var isUpdatingLocation = false
    
    /**
    Timer to send the cumulative count to the watch.
    To avoid polluting IDS traffic, its better to send batch updates to the watch
    instead of sending the updates as they arrive.
    */
    var sessionMessageTimer = NSTimer()
    
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var region: MKCoordinateRegion = MKCoordinateRegion()
    
    
    // MARK: Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    /**
    Sets the delegates and activate the `WCSession`.
    
    The `WCSession` needs to be activated in the init methods so that when the
    app is launched into the background when it wasn't previously running, the
    session can still be activated allowing communication between the watch and
    the phone. Activating the session in the `viewDidLoad()` method wont suffice
    since the `viewDidLoad()` method will not be called if the app is launched
    into the background.
    */
    func commonInit() {
        
        // Initialize the `WCSession` and the `CLLocationManager`.
        session.delegate = self
        session.activateSession()
        
        manager.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //hard coding in case of internet issues
        if (false) {
            let location = CLLocation(latitude: 37.7586, longitude: -122.3844)
            self.location = CLLocationCoordinate2D(latitude: 37.7586, longitude: -122.3844)
            let region = MKCoordinateRegion(center: self.location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
            self.mapView.setRegion(region, animated: true)
            centerMapOnLocation(location)
        
            // Add an annotation on Map View
            let point: MKPointAnnotation! = MKPointAnnotation()
            point.coordinate = location.coordinate
            self.mapView.addAnnotation(point)
        } else {
            self.locationManager.requestAlwaysAuthorization()
            self.locationManager.startUpdatingLocation()
        }
        
        mapView.mapType = MKMapType.Standard
        mapView.showsUserLocation = true
    }
    
    /**
    Starts updating location and allows the app to receive background location
    updates.
    
    This method also sets the view into a state that lets the user know that
    the manager has started updating location, as well as starts the batch timer
    for sending location counts to the watch.
    
    Use `commandedFromPhone` to determine whether or not to call `requestWhenInUseAuthorization()`.
    If this method was called due to a command from the watch, the watch should
    be responsible for requesting authorization, and therefore this method
    should not request authorization. This ensures that the authorization prompt
    will come from the device that the user is currently interacting with.
    */
    func startUpdatingLocationAllowingBackground(commandedFromPhone commandedFromPhone: Bool) {
        isUpdatingLocation = true
        /*
        When commanding from the phone, request authorization and inform the
        watch app of the state change.
        */
        if commandedFromPhone {
            manager.requestWhenInUseAuthorization()
            
            do {
                try session.updateApplicationContext([
                    MessageKey.StateUpdate.rawValue: isUpdatingLocation,
                    ])
            }
            catch let error as NSError {
                print("Error when updating application context \(error.localizedDescription).")
            }
        }
        
        manager.allowsBackgroundLocationUpdates = true
        
        manager.startUpdatingLocation()
        
        sessionMessageTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "sendLocationCount", userInfo: nil, repeats: true)
        
    }
    
    /**
    Informs the manager to stop updating location, invalidates the timer, and
    updates the view.
    
    If the command comes from the phone, this method sends a state update to
    the watch to inform the watch that location updates have stopped.
    */
    func stopUpdatingLocation(commandedFromPhone commandedFromPhone: Bool) {
        isUpdatingLocation = false
        /*
        When commanding from the phone, request authorization and inform the
        watch app of the state change.
        */
        if commandedFromPhone {
            do {
                try session.updateApplicationContext([
                    MessageKey.StateUpdate.rawValue: isUpdatingLocation,
                    ])
            }
            catch let error as NSError {
                print("Error when updating application context \(error.localizedDescription)")
            }
        }
        
        manager.stopUpdatingLocation()
        
        manager.allowsBackgroundLocationUpdates = false
        
        sessionMessageTimer.invalidate()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
    On the receipt of a message, check for expected commands.
    
    On a `startUpdatingLocation` command, inform the manager to start updating
    location, and start a repeating 5 second timer that sends the cumulative
    location count to the watch.
    
    On a `stopUpdatingLocation` command, inform the manager to stop updating
    location, and stop the repeating timer.
    */
    func session(session: WCSession, didReceiveMessage message: [String: AnyObject], replyHandler: [String: AnyObject] -> Void) {
        guard let messageCommandString = message[MessageKey.Command.rawValue] as? String else { return }
        
        guard let messageCommand = MessageCommand(rawValue: messageCommandString) else {
            print("Unknown command \(messageCommandString).")
            return
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            switch messageCommand {
            case .StartUpdatingLocation:
                self.startUpdatingLocationAllowingBackground(commandedFromPhone: false)
                
                replyHandler([
                    MessageKey.Acknowledge.rawValue: messageCommand.rawValue
                    ])
                
            case .StopUpdatingLocation:
                self.stopUpdatingLocation(commandedFromPhone: false)
                
                replyHandler([
                    MessageKey.Acknowledge.rawValue: messageCommand.rawValue
                    ])
                
            case .SendLocationStatus:
                replyHandler([
                    MessageKey.Acknowledge.rawValue: self.isUpdatingLocation
                    ])
            }
        }
    }
    
    /**
    Send the current cumulative location to the watch and reset the batch
    count to zero.
    */
    func sendLocationCount() {
        do {
            try session.updateApplicationContext([
                MessageKey.StateUpdate.rawValue: isUpdatingLocation,
                ])
        }
        catch let error as NSError {
            print("Error when updating application context \(error).")
        }
    }
    
    
    /**
    Increases that location count by the number of locations received by the
    manager. Updates the batch count with the added locations.
    */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        self.location = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: self.location, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        
        self.mapView.setRegion(region, animated: true)
        centerMapOnLocation(location!)
        
        // Add an annotation on Map View
        let point: MKPointAnnotation! = MKPointAnnotation()
        point.coordinate = location!.coordinate
        self.mapView.addAnnotation(point)
        
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
    }
    
    /// Log any errors to the console.
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error occured: \(error.localizedDescription).")
    }
    
    func centerMapOnLocation(location: CLLocation) {
        self.region = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(region, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createARequest" {
            let createRequestViewController: CreateRequestViewController = segue.destinationViewController as! CreateRequestViewController
            createRequestViewController.location = self.location
            createRequestViewController.region = self.region
        }
    }
    
    
}

