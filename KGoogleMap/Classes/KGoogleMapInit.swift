//
//  KGoogleMapInit.swift
//  KGoogleMap
//
//  Created by Michelle Raouf on 29/09/2024.
//

import Foundation
import GoogleMaps

@objc  public class KGoogleMapInit: NSObject {
   static var apiKey:String? = nil
    @objc public static func provideAPIKey(key: String) {
        apiKey = key
        GMSServices.provideAPIKey(key)
    }
}
