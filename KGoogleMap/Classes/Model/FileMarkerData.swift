//
//  FileMarkerData.swift
//  KGoogleMap
//
//  Created by Michelle Raouf on 29/09/2024.
//

import Foundation
import  GoogleMaps

@objc class MarkerData : NSObject{
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var title: String
    var snippet: String
    var icon: UIImage? // Optional icon for custom markers
    
    @objc init(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String, snippet: String, icon: UIImage? = nil) {
          self.latitude = latitude
          self.longitude = longitude
          self.title = title
          self.snippet = snippet
          self.icon = icon
      }
}
