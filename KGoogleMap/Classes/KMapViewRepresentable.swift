// KMapViewRepresentable.swift
// KGoogleMap
//
// Created by Michelle Raouf on 29/09/2024.
import UIKit
import GooglePlaces
import GoogleMaps

public class KMapViewRepresentable: UIViewController, GMSAutocompleteViewControllerDelegate {
    var mapView: GMSMapView!
    var camera: GMSCameraPosition?
    var markers: [MarkerData] = []
    var showCurrentLocation: Bool = false
    var locationManager = CLLocationManager()

    private var routePolyline: GMSPolyline?
    var isRouteVisible: Bool = true
    private var currentCircleOverlay: GMSCircle? = nil
    
    public var didSelectLocation: ((LocationData) -> Void)?


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

    
    public override func viewDidLoad() {
           super.viewDidLoad()
           setupUI()
       }

       // Set up your custom UI (e.g., buttons, labels)
       private func setupUI() {
           // Example: Adding a button to trigger the search
           let searchButton = UIButton(type: .system)
           searchButton.setTitle("Search Places", for: .normal)
           searchButton.addTarget(self, action: #selector(openPlaceSearch), for: .touchUpInside)
           searchButton.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(searchButton)

           // Set up constraints for your button (or other UI components)
           NSLayoutConstraint.activate([
               searchButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               searchButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
           ])
       }

       @objc public func openPlaceSearch() {
           // Initialize and set up the GMSAutocompleteViewController
           let autocompleteController = GMSAutocompleteViewController()
           autocompleteController.delegate = self

           // Customize the autocomplete filter
           let filter = GMSAutocompleteFilter()
           filter.types = ["*"] // Adjust type filters as needed
           autocompleteController.autocompleteFilter = filter

           // Present the autocomplete view controller
           present(autocompleteController, animated: true, completion: nil)
       }

       // MARK: - GMSAutocompleteViewControllerDelegate Methods

       public func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
           // Handle the place selection
           let locationData = LocationData(
               name: place.name,
               latitude: place.coordinate.latitude,
               longitude: place.coordinate.longitude
           )
           
           didSelectLocation?(locationData)


           // Dismiss the autocomplete controller
           viewController.dismiss(animated: true, completion: nil)
       }

       public func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
           print("Autocomplete error: \(error.localizedDescription)")
           viewController.dismiss(animated: true, completion: nil)
       }

       public func wasCancelled(_ viewController: GMSAutocompleteViewController) {
           print("Autocomplete was cancelled.")
           viewController.dismiss(animated: true, completion: nil)
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
