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

let grayBorder: CGColor = UIColor(red: 201.0/255.0, green: 201.0/255.0, blue: 201.0/255.0, alpha: 1.0).CGColor

class CreateRequestViewController: UIViewController {
    var location: CLLocationCoordinate2D?
    var region: MKCoordinateRegion?
    
    let regionRadius: CLLocationDistance = 1000
    
    var durationInMinutes: Float = 30
    
    let requestURL = "http://172.20.10.3:8080/request"
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationView: UIView!
    @IBOutlet weak var paymentView: UIView!
    
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
        
        self.durationView.layer.borderColor = grayBorder
        self.paymentView.layer.borderColor = grayBorder
                
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
                durationValue = String(format: "%.0f hours, ", hour)
            } else {
                durationValue = String(format: "%.0f hour, ", hour)
            }
        }
        
        let minutes: Float = self.durationInMinutes % 60.0
        
        let minutesValue = minutes > 1
            ? String(format: "%.0f minutes", minutes)
            : String(format: "%.0f minute", minutes)
        
        
        self.durationLabel.text = "\(durationValue)\(minutesValue)"
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegionMakeWithDistance(location, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(region, animated: false)
    }
    
    @IBAction func showDurationPicker(sender: AnyObject) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let durationViewController: DurationViewController = storyBoard.instantiateViewControllerWithIdentifier("durationViewController") as! DurationViewController
        
        durationViewController.view.backgroundColor = UIColor.clearColor()
        self.performSegueWithIdentifier("durationSegue", sender: self)
    }
    
    @IBAction func completeRequest(sender: AnyObject) {
        let query = self.requestURL
        let url: NSURL = NSURL(string: query)!
        
        let lat: Double = Double((self.location?.latitude)!)
        let long: Double = Double((self.location?.longitude)!)
        
        let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let params = ["customerId":"1", "lat":lat, "lon":long, "minutes": self.durationInMinutes]
        
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
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "durationSegue" {
            let durationViewController = segue.destinationViewController as! DurationViewController
            durationViewController.createRequestViewController = self
            durationViewController.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        }
        
        if segue.identifier == "meterRequest" {
            let meterViewController: MeterViewController = segue.destinationViewController as! MeterViewController
            meterViewController.location = self.location
            meterViewController.region = self.region
            meterViewController.duration = self.durationInMinutes
        }
    }
}
