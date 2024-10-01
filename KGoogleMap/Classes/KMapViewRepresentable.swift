// KMapViewRepresentable.swift
// KGoogleMap
//
// Created by Michelle Raouf on 29/09/2024.
import UIKit
import GoogleMaps

public class KMapViewRepresentable: UIViewController {
    var mapView: GMSMapView!
    var camera: GMSCameraPosition?
    var markers: [MarkerData] = []
    var showCurrentLocation: Bool = false
    var locationManager = CLLocationManager()

    // New property to manage route visibility
    private var routePolyline: GMSPolyline?
    var isRouteVisible: Bool = false
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
   private  func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Method to add markers to the map
    func addMarkers(to mapView: GMSMapView) {
        // Check if markers array is empty
        guard !markers.isEmpty else {
            print("No markers to add.")
            return // Early exit if markers is empty
        }

        // Add each marker from the markers array
        for markerData in markers {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: markerData.latitude, longitude: markerData.longitude)
            marker.title = markerData.title
            marker.snippet = markerData.snippet
            
            // Set the custom icon if provided
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

        // Clear the existing marker before adding a new one
        if currentCircleOverlay != nil {
            currentCircleOverlay?.map = nil // Remove existing overlay from map
        }

        // Create a new circular overlay to indicate the user's location
        currentCircleOverlay = GMSCircle(position: currentLocation, radius: 40)
        currentCircleOverlay!.fillColor = UIColor.blue.withAlphaComponent(0.5)
        currentCircleOverlay!.strokeColor = UIColor.blue
        currentCircleOverlay!.strokeWidth = 2
        currentCircleOverlay!.map = mapView
    }

    
    private func clearCurrentLocationMarker() {
        if let currentCircleOverlay = currentCircleOverlay {
            print("Clearing current location marker.")
            currentCircleOverlay.map = nil // Remove the circle overlay from the map
            self.currentCircleOverlay = nil // Set the reference to nil
            mapView.clear()
            print("Current location marker cleared.")
        } else {
            print("No current location marker to clear.")
        }
    }



    // Method to fetch route between two coordinates
    func fetchRoute(from origin: CLLocationCoordinate2D?, to destination: CLLocationCoordinate2D) {
        print("Fetching route...")

        let originCoordinate: CLLocationCoordinate2D
        if let origin = origin {
            originCoordinate = origin
        } else if let currentLocation = currentCircleOverlay?.position {
            originCoordinate = currentLocation
        } else {
            print("No valid origin provided and current location is not available.")
            return
        }

        guard let apiKey = KGoogleMapInit.apiKey, !apiKey.isEmpty else {
            print("API Key is missing.")
            return
        }
        
        let originString = "\(originCoordinate.latitude),\(originCoordinate.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching directions: \(String(describing: error))")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let overviewPolyline = routes.first?["overview_polyline"] as? [String: Any],
                   let points = overviewPolyline["points"] as? String {
                    self.drawRoute(from: points)
                    print("Route successfully fetched and drawn.")
                } else {
                    print("No routes found in response.")
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }

    // Method to draw route and control visibility
    private func drawRoute(from points: String) {
        // Decode the polyline points into CLLocationCoordinate2D array
        let path = GMSPath(fromEncodedPath: points)

        // If routePolyline already exists, remove it from the map
        routePolyline?.map = nil

        // Create a new polyline with the new path
        routePolyline = GMSPolyline(path: path)
        routePolyline?.strokeColor = .blue
        routePolyline?.strokeWidth = 5.0
        if isRouteVisible {
            routePolyline?.map = mapView // Show the polyline on the map
        }
    }

    // Method to set route visibility
    func setRouteVisibility(_ visible: Bool) {
        isRouteVisible = visible
        routePolyline?.map = visible ? mapView : nil // Show or hide the polyline based on visibility
    }
    
    func showUserLocation(){
        if showCurrentLocation {
            addCurrentLocationMarker() // Call the new method to add the current location marker
        } else {
            clearCurrentLocationMarker()
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension KMapViewRepresentable: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let coordinate = location.coordinate

        // Print the updated location
        print("Updated location: \(coordinate.latitude), \(coordinate.longitude)")
        
        // Update the current location marker
        mapView.animate(toLocation: coordinate)
        showUserLocation() // Call showUserLocation to update marker
    }

}
