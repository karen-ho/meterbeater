//
//  CreateRequestViewController.swift
//  MeterBeater
//
//  Created by Karen Ho on 9/19/15.
//  Copyright © 2015 Karen Ho. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CreateRequestViewController: UIViewController {
    var location: CLLocationCoordinate2D?
    var region: MKCoordinateRegion?
    
    let regionRadius: CLLocationDistance = 1000
    
    var durationInMinutes: Float = 30
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var durationLabel: UILabel!
    
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
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setDurationLabel() {
        var durationValue: String = ""
        let hour: Float = floor(self.durationInMinutes/60.0)
        
        if hour > 0 {
            if hour > 1 {
                durationValue = String(format: "%.f hours", hour)
            } else {
                durationValue = String(format: "%.f hour", hour)
            }
        }
        
        let minutes: Float = self.durationInMinutes % 60.0
        
        self.durationLabel.text = String(format: "%s, %.f minutes", durationValue, minutes)
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(region, animated: false)
    }
    
    @IBAction func showDurationPicker(sender: AnyObject) {
        NSLog("HII")
    }
}
