//
//  MeterViewController.swift
//  MeterBeater
//
//  Created by Karen Ho on 9/20/15.
//  Copyright © 2015 Karen Ho. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import MMX

class MeterViewController: UIViewController {
    var location: CLLocationCoordinate2D?
    var region: MKCoordinateRegion?
    var duration: Float?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationView: UIView!
    
    let regionRadius: CLLocationDistance = 1000
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        MMX.start()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "didReceiveMessage:",
            name: MMXDidReceiveMessageNotification,
            object: nil)
    }
    
    func didReceiveMessage(notification: NSNotification) {
        let userInfo : [NSObject : AnyObject] = notification.userInfo!
        let message = userInfo[MMXMessageKey] as! MMXMessage
        message.sendDeliveryConfirmation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func didReceiveDeliveryConfirmation(notification: NSNotification) {
        let userInfo : [NSObject : AnyObject] = notification.userInfo!
        let recipient = userInfo[MMXRecipientKey] as! MMXUser
        let messageID = userInfo[MMXMessageIDKey] as! MMXUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let currentLocation = self.location {
            let region = MKCoordinateRegion(center: currentLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: false)
            
            centerMapOnLocation(currentLocation)
            
            // Add an annotation on Map View
            let point: MKPointAnnotation! = MKPointAnnotation()
            point.coordinate = currentLocation
            self.mapView.addAnnotation(point)
            
            if let durationInMinutes = self.duration {
                updateDurationLabel(durationInMinutes)
            }
        }
        
        _ = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        self.durationView.layer.borderColor = grayBorder
    }
    
    func update() {
        if let durationInMinutes = self.duration {
            self.duration = durationInMinutes - 1
            updateDurationLabel(durationInMinutes - 1)
        }
    }
    
    func updateDurationLabel(durationInMinutes: Float) {
        var durationValue: String = ""
        let hour: Float = floor(durationInMinutes/60.0)
        
        if hour > 0 {
            if hour > 1 {
                durationValue = String(format: "%.0f hours, ", hour)
            } else {
                durationValue = String(format: "%.0f hour, ", hour)
            }
        }
        
        let minutes: Float = durationInMinutes % 60.0
        
        let minutesValue = minutes > 1
            ? String(format: "%.0f minutes", minutes)
            : String(format: "%.0f minute", minutes)
        
        
        self.durationLabel.text = "\(durationValue)\(minutesValue)"
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(region, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelRequest(sender: AnyObject) {
        let cancelRequest = UIAlertController(title: "Cancel Request", message: "Stop request to refill my meter?", preferredStyle: UIAlertControllerStyle.Alert)
        cancelRequest.addAction(UIAlertAction(title: "No", style: .Default, handler: {(action: UIAlertAction!) in
            NSLog("cancel")
        }))
        cancelRequest.addAction(UIAlertAction(title: "Yes", style: .Default, handler: {(action: UIAlertAction!) in
            self.performSegueWithIdentifier("backToStart", sender: self)
        }))
        presentViewController(cancelRequest, animated: true, completion: nil)
    }
    
}