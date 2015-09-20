//
//  DurationPickerView.swift
//  MeterBeater
//
//  Created by Karen Ho on 9/20/15.
//  Copyright © 2015 Karen Ho. All rights reserved.
//

import Foundation
import UIKit

class DurationPickerView: UIView {
    @IBOutlet weak var durationPicker: UIPickerView!
    @IBOutlet weak var container: UIView!
    
    override convenience init() {
        self.init(nibName: "DurationPic")
    }
}