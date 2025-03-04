//  locationManager.swift
//  Pods
//
//  Created by Michelle Raouf on 08/12/2024.

import CoreLocation

public class LocationListener: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    private var locationUpdateHandler: ((CLLocation) -> Void)?
    private var lastUpdateTimestamp: Date?
    private var updateDelay: TimeInterval

    public init(updateDelay: TimeInterval = 10.0) {
        self.locationManager = CLLocationManager()
        self.updateDelay = updateDelay
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }

    public func setUpdateDelay(_ delay: TimeInterval) {
        self.updateDelay = delay
    }

    public func setLocationUpdateHandler(_ handler: @escaping (CLLocation) -> Void) {
        self.locationUpdateHandler = handler
    }

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            print("Location access denied or restricted.")
        default:
            print("Waiting for location authorization.")
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }

        let currentTime = Date()
        if let lastUpdate = lastUpdateTimestamp {
            let timeInterval = currentTime.timeIntervalSince(lastUpdate)
            if timeInterval >= updateDelay {
                lastUpdateTimestamp = currentTime
                DispatchQueue.main.async {
                    self.locationUpdateHandler?(newLocation)
                }
            }
        } else {
            lastUpdateTimestamp = currentTime
            DispatchQueue.main.async {
                self.locationUpdateHandler?(newLocation)
            }
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
