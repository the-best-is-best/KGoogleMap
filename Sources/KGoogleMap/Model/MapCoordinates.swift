//
//  MapCoordinates.swift
//  KGoogleMap
//
//  Created by Michelle Raouf on 30/09/2024.
//

// MapCoordinates.swift

import Foundation

@objc public class MapCoordinates: NSObject {
    @objc public var startLatitude: NSNumber?
    @objc public var startLongitude: NSNumber?
    @objc public var endLatitude: NSNumber?
    @objc public var endLongitude: NSNumber?
    
    @objc public init(startLatitude: NSNumber? = nil,
                      startLongitude: NSNumber? = nil,
                      endLatitude: NSNumber? = nil,
                      endLongitude: NSNumber? = nil) {
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
    }
}
