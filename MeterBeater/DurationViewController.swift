//
//  DurationViewController.swift
//  MeterBeater
//
//  Created by Karen Ho on 9/20/15.
//  Copyright © 2015 Karen Ho. All rights reserved.
//

import Foundation
import UIKit

class DurationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var durationPicker: UIPickerView!
    var pickerData: [String] = [String]()
    var duration: Int = 30
    
    weak var createRequestViewController: CreateRequestViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerData.append("1 minute")
        
        for minute in 2...300 {
            self.pickerData.append("\(minute) minutes")
        }
        
        self.durationPicker.selectRow(29, inComponent: 0, animated: false)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        NSLog("\(row+1)")
        self.duration = row+1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    @IBAction func dismissDurationPicker(sender: AnyObject) {
        self.createRequestViewController?.durationInMinutes = Float(self.duration)
        self.createRequestViewController?.setDurationLabel()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
