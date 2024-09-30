// KMapView.swift
// KGoogleMap
//
// Created by Michelle Raouf on 29/09/2024.
//
import SwiftUI
import GoogleMaps


// MARK: - KMapView Wrapper
@objc public class KMapView: UIView {
    private var mapViewController: KMapViewRepresentable?

    // Initialization method with camera, markers, and showCurrentLocation option
    @objc public init(camera: GMSCameraPosition? = nil,
                     markers: [MarkerData] = [],
                     showCurrentLocation: Bool = false) {
        super.init(frame: .zero)
        setupMapView(camera: camera,
                     markers: markers,
                     showCurrentLocation: showCurrentLocation)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // Setup the map view with the given parameters
    private func setupMapView(camera: GMSCameraPosition?,
                              markers: [MarkerData],
                              showCurrentLocation: Bool) {
        
        mapViewController = KMapViewRepresentable(camera: camera,
                                                  markers: markers,
                                                  showCurrentLocation: showCurrentLocation)
        
        guard let mapViewController = mapViewController else { return }

        // Embed the mapViewController's view into the KMapView
        mapViewController.view.frame = self.bounds
        mapViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(mapViewController.view)

        // Attach the view controller to a parent view controller if available
        if let parentViewController = findViewController() {
            parentViewController.addChild(mapViewController)
            mapViewController.didMove(toParent: parentViewController)
        }
    }

    // Utility function to find the nearest parent view controller
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            responder = responder?.next
            if let viewController = responder as? UIViewController {
                return viewController
            }
        }
        return nil
    }

    // Method to update markers dynamically
    @objc public func updateMarkers(_ markers: [MarkerData]) {
        mapViewController?.markers = markers
        mapViewController?.addMarkers(to: mapViewController?.mapView)
    }

    // Method to set the route between two points
    @objc public func fetchRoute(startLat: NSNumber? = nil, startLong: NSNumber? = nil, endLat: NSNumber, endLong: NSNumber) {
        // Print the type of end for debugging
        print("End Latitude: \(endLat), End Longitude: \(endLong)")

        // Create the end coordinate using the provided latitude and longitude
        let endCoordinate = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(truncating: endLat),
            longitude: CLLocationDegrees(truncating: endLong)
        )

        var startCoordinate: CLLocationCoordinate2D?

        // Check if startLat and startLong are provided
        if let startLat = startLat, let startLong = startLong {
            // If provided, create CLLocationCoordinate2D
            startCoordinate = CLLocationCoordinate2D(
                latitude: CLLocationDegrees(truncating: startLat),
                longitude: CLLocationDegrees(truncating: startLong)
            )
        } else {
            // If not provided, get the current user location
            if let currentLocation = mapViewController?.locationManager.location {
                startCoordinate = currentLocation.coordinate
                print("Using current location as start coordinate: \(startCoordinate!)")
            } else {
                print("Current location is not available.")
                return
            }
        }

        // Call the fetchRoute method on the map view controller
        mapViewController?.fetchRoute(from: startCoordinate, to: endCoordinate)
    }



    // Method to clear all markers
    @objc public func clearMarkers() {
        mapViewController?.markers.removeAll()
        mapViewController?.mapView?.clear()
    }

    // Method to zoom to a specific location with a zoom level
    @objc public func zoomToLocation(_ location: CLLocationCoordinate2D, zoom: Float = 15.0) {
        let cameraUpdate = GMSCameraUpdate.setTarget(location, zoom: zoom)
        mapViewController?.mapView?.animate(with: cameraUpdate)
    }

    // Method to reset the camera to its initial position
    @objc public func resetCameraPosition() {
        if let initialCamera = mapViewController?.camera {
            mapViewController?.mapView?.animate(to: initialCamera)
        }
    }

    // Method to set a new camera position
    @objc public func setCameraPosition(_ cameraPosition: GMSCameraPosition) {
        mapViewController?.mapView?.camera = cameraPosition
    }

    // Method to show or hide the user's current location
    @objc public func showUserLocation(_ show: Bool) {
        mapViewController?.showCurrentLocation = show
        if show {
            mapViewController?.locationManager.delegate = mapViewController // Set delegate
            mapViewController?.locationManager.startUpdatingLocation()
        } else {
            mapViewController?.locationManager.stopUpdatingLocation()
            mapViewController?.currentLocationMarker?.map = nil
        }
    }
}
