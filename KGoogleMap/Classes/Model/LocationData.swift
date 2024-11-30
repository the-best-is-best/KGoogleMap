//
//  LocationData.swift
//  Pods
//
//  Created by Michelle Raouf on 30/11/2024.
//

import Foundation

@objc public class LocationData: NSObject {
    @objc public var name: String?
    @objc public  var latitude: Double
    @objc public  var longitude: Double
    
    @objc public init(name: String? = nil, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}
