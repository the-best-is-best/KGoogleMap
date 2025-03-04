//
//  GMSPathExt.swift
//  Pods
//
//  Created by Michelle Raouf on 02/10/2024.
//
import GoogleMaps
import GoogleMapsUtils

// Extension to get coordinates from GMSPath
extension GMSPath {
    func coordinates() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        for index in 0..<self.count() {
            coords.append(self.coordinate(at: index))
        }
        return coords
    }
}



