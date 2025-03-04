//
//  KGoogleMapInit.swift
//  KGoogleMap
//
//  Created by Michelle Raouf on 29/09/2024.
//

import Foundation
import GoogleMaps
import GooglePlaces

@objc public class KGoogleMapInit: NSObject {
    private static var apiKey: String? = nil
    private static let apiKeyQueue = DispatchQueue(label: "com.yourapp.KGoogleMapInitQueue")
    
    @objc public static func provideAPIKey(key: String) {
        apiKeyQueue.sync {
            // Ensure the key is not nil and prevent redundant assignment
            guard apiKey != key else {
                return // API key already set, no need to do anything
            }
            
            apiKey = key
            GMSServices.provideAPIKey(key)
            GMSPlacesClient.provideAPIKey(key)
        }
    }
}
