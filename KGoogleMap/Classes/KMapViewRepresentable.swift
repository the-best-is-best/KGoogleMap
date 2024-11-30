// KMapViewRepresentable.swift
// KGoogleMap
//
// Created by Michelle Raouf on 29/09/2024.
import UIKit
import GoogleMaps
import CoreLocation

public class KMapViewRepresentable: UIViewController {
    var mapView: GMSMapView!
    var camera: GMSCameraPosition?
    var markers: [MarkerData] = []
    var showCurrentLocation: Bool = false
    var locationManager = CLLocationManager()

    private var routePolyline: GMSPolyline?
    var isRouteVisible: Bool = true
    private var currentCircleOverlay: GMSCircle? = nil

    // Initialization method
    init(camera: GMSCameraPosition?, markers: [MarkerData]?, showCurrentLocation: Bool) {
        self.camera = camera
        self.markers = markers ?? [] // Use an empty array if markers is nil
        self.showCurrentLocation = showCurrentLocation
        super.init(nibName: nil, bundle: nil)
        setupMapView()
        setupLocationManager()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Setup map view
    private func setupMapView() {
        mapView = GMSMapView()
        if let camera = camera {
            mapView.camera = camera
        }
        view = mapView
        addMarkers(to: mapView)
    }

    // Setup location manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Method to add markers to the map
    func addMarkers(to mapView: GMSMapView) {
        guard !markers.isEmpty else {
            return // Early exit if markers is empty
        }

        for markerData in markers {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: markerData.latitude, longitude: markerData.longitude)
            marker.title = markerData.title
            marker.snippet = markerData.snippet

            if let icon = markerData.icon {
                marker.icon = icon
            }

            marker.map = mapView
        }
    }

    // Method to add a marker for the user's current location
    private func addCurrentLocationMarker() {
        guard let location = locationManager.location else { return }

        let currentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if currentCircleOverlay != nil {
            currentCircleOverlay?.map = nil
        }

        currentCircleOverlay = GMSCircle(position: currentLocation, radius: 40)
        currentCircleOverlay?.fillColor = UIColor.blue.withAlphaComponent(0.5)
        currentCircleOverlay?.strokeColor = UIColor.blue
        currentCircleOverlay?.strokeWidth = 2
        currentCircleOverlay?.map = mapView

        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude, longitude: currentLocation.longitude, zoom: 15)
        mapView.animate(to: camera)
    }

    private func clearCurrentLocationMarker() {
        if let currentCircleOverlay = currentCircleOverlay {
            currentCircleOverlay.map = nil // Remove the circle overlay from the map
            self.currentCircleOverlay = nil
        }
        mapView.clear() // Clears all markers and overlays
    }

    func renderRoad(_ points: String) {
        guard let coordinates = decodePolyline(points) else {
            print("Failed to create GMSPath from encoded path")
            return
        }

        routePolyline?.map = nil // Remove the old polyline if it exists

        let path = GMSMutablePath()
        coordinates.forEach { path.add($0) }

        routePolyline = GMSPolyline(path: path)
        routePolyline?.strokeColor = .blue
        routePolyline?.strokeWidth = 10.0

        if isRouteVisible {
            routePolyline?.map = mapView
        }
    }

    private func decodePolyline(_ encoded: String) -> [CLLocationCoordinate2D]? {
        return GMSPath(fromEncodedPath: encoded)?.coordinates()
    }

    func setRouteVisibility(_ visible: Bool) {
        isRouteVisible = visible
        routePolyline?.map = visible ? mapView : nil
    }

    func showUserLocation() {
        if showCurrentLocation {
            addCurrentLocationMarker()
        } else {
            clearCurrentLocationMarker()
        }
    }

    private func updateCurrentLocation() {
        guard let location = locationManager.location else { return }

        if showCurrentLocation {
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 15)
            mapView.animate(to: camera)
        }
    }

    func searchAddress(searchString: String) async -> LocationData? {
        let geocoder = CLGeocoder()
        var locationData: LocationData?

        // Create a CLLocation instance from the search string (assuming it's an address)
        // This step requires some way to resolve a string to a coordinate, like a forward geocoding call.
        do {
            // Assuming searchString is an address or location name, use forward geocoding first
            let location = try await geocoder.geocodeAddressString(searchString)
            
            guard let placemark = location.first else {
                print("No placemark found.")
                return nil
            }

            print("Placemark details: \(placemark)")

            // Extract relevant information from the placemark
            let streetName = placemark.thoroughfare?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
            let locality = placemark.locality?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
            let subThoroughfare = placemark.subThoroughfare?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
            let postalCode = placemark.postalCode?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""
            let administrativeArea = placemark.administrativeArea?.trimmingCharacters(in: .whitespaces).lowercased() ?? ""

            print("Street Name: \(streetName)")
            print("Locality: \(locality)")
            print("SubThoroughfare: \(subThoroughfare)")
            print("Postal Code: \(postalCode)")
            print("Administrative Area: \(administrativeArea)")

            // Check if any of the placemark details match the search string (custom matching logic)
       
                // Create and return a LocationData instance here as needed
                locationData = LocationData(name: streetName, latitude: placemark.location!.altitude, longitude: placemark.location!.altitude)
           
        } catch {
            print("Error during geocoding: \(error)")
        }

        return locationData
    }

}

// MARK: - CLLocationManagerDelegate
extension KMapViewRepresentable: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate
        print("Updated location: \(coordinate.latitude), \(coordinate.longitude)")

        if showCurrentLocation {
            let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 15)
            mapView.animate(to: camera)
        }

        showUserLocation()
    }
}
