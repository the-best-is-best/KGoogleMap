//
//  CameraPosition.swift
//  KGoogleMap
//
//  Created by Michelle Raouf on 04/03/2025.
//

import Foundation

@objc public class CameraPosition: NSObject {
    @objc public  var latitude: Double
    @objc public  var longitude: Double
    @objc public  var zoom: Float
    
    @objc public init(latitude: Double, longitude: Double, zoom: Float) {
        self.latitude = latitude
        self.longitude = longitude
        self.zoom = zoom
    }
}
