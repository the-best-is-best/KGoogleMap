//  locationManager.swift
//  Pods
//
//  Created by Michelle Raouf on 08/12/2024.

import CoreLocation

// Public class to handle location updates with a delay
public class LocationListener: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    private var locationUpdateHandler: ((CLLocation) -> Void)?
    private var lastUpdateTimestamp: Date?
    private var updateDelay: TimeInterval // Delay in seconds (default value can be set)

    // Public initializer with a default update interval
    public init(updateDelay: TimeInterval = 10.0) {
        self.locationManager = CLLocationManager()
        self.updateDelay = updateDelay
        super.init() // Calls the designated initializer of NSObject
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        print("LocationManager initialized and started with update delay of \(updateDelay) seconds.")
    }
    
    // Method to set the update delay dynamically
    public func setUpdateDelay(_ delay: TimeInterval) {
        self.updateDelay = delay
        print("Update delay set to \(delay) seconds.")
    }

    public func setLocationUpdateHandler(_ handler: @escaping (CLLocation) -> Void) {
        self.locationUpdateHandler = handler
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager start")
        guard let newLocation = locations.last else {
            print("No new location available.")
            return
        }
        print("Received new location: \(newLocation.coordinate.latitude), \(newLocation.coordinate.longitude)")
        
        let currentTime = Date()
        
        if let lastUpdate = lastUpdateTimestamp {
            let timeInterval = currentTime.timeIntervalSince(lastUpdate)
            if timeInterval >= updateDelay {
                lastUpdateTimestamp = currentTime
                print("Location update accepted (delay check passed).")
                locationUpdateHandler?(newLocation)
            } else {
                print("Update ignored due to delay.")
            }
        } else {
            lastUpdateTimestamp = currentTime
            print("First location update.")
            locationUpdateHandler?(newLocation)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
