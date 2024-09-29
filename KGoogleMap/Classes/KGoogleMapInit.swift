//
//  KGoogleMapInit.swift
//  KGoogleMap
//
//  Created by Michelle Raouf on 29/09/2024.
//

import Foundation
import GoogleMaps

@objc  public class KGoogleMapInit: NSObject {
    @objc public static func provideAPIKey(key: String) {
        GMSServices.provideAPIKey(key)
    }
}
