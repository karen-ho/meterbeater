//
//  Request.swift
//  MeterBeater
//
//  Created by Karen Ho on 9/19/15.
//  Copyright © 2015 Karen Ho. All rights reserved.
//

import Foundation
import CoreLocation

class Request {
    var timeInMinutes: Float
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var coordinate: CLLocationCoordinate2D
    
    init(timeInMinutes: Float, latitude: CLLocationDegrees, longitude: CLLocationDegrees, coordinate: CLLocationCoordinate2D) {
        self.timeInMinutes = timeInMinutes
        self.latitude = latitude
        self.longitude = longitude
        self.coordinate = coordinate
    }
}