import SwiftUI
import GoogleMaps
import CoreLocation

public class KMapViewRepresentable: UIViewController {
    var mapView: GMSMapView!
    var camera: GMSCameraPosition?
    var markers: [MarkerData] = []
    var currentLocationMarker: GMSMarker?
    var showCurrentLocation: Bool = false
    var locationManager = CLLocationManager()

    // Initialization method
    init(camera: GMSCameraPosition?, markers: [MarkerData], showCurrentLocation: Bool) {
        self.camera = camera
        self.markers = markers
        self.showCurrentLocation = showCurrentLocation
        super.init(nibName: nil, bundle: nil)
        setupMapView()
        setupLocationManager()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Set up the map view
    private func setupMapView() {
        mapView = GMSMapView() // Ensure frame is set correctly
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // Allow resizing
        mapView.isMyLocationEnabled = showCurrentLocation
        view.addSubview(mapView)

        addMarkers(to: mapView)
    }


    // Set up the location manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }

    func addMarkers(to mapView: GMSMapView?) {
        mapView?.clear()

        for markerData in markers {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: markerData.latitude, longitude: markerData.longitude)
            marker.title = markerData.title
            marker.snippet = markerData.snippet
            marker.map = mapView
        }

    
    }

    private func addCurrentLocationMarker() {
        guard let location = locationManager.location else { return }

        let currentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)

        let circleOverlay = GMSCircle(position: currentLocation, radius: 20)
        circleOverlay.fillColor = UIColor.blue.withAlphaComponent(0.5)
        circleOverlay.strokeColor = UIColor.blue
        circleOverlay.strokeWidth = 2
        circleOverlay.map = mapView

      
        currentLocationMarker?.position = currentLocation
        currentLocationMarker?.map = mapView
    }

    func fetchRoute(from origin: CLLocationCoordinate2D?, to destination: CLLocationCoordinate2D) {
        let originCoordinate: CLLocationCoordinate2D
        if let origin = origin {
            originCoordinate = origin
        } else if let currentLocation = currentLocationMarker?.position {
            originCoordinate = currentLocation
        } else {
            print("No valid origin provided and current location is not available.")
            return
        }

        let apiKey = KGoogleMapInit.apiKey
        let originString = "\(originCoordinate.latitude),\(originCoordinate.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&key=\(apiKey!)"

        guard let url = URL(string: urlString) else { return }

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
                } else {
                    print("No routes found in response.")
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        task.resume()
    }

    private func drawRoute(from points: String) {
        // Decode the polyline points into CLLocationCoordinate2D array
        let path = GMSPath(fromEncodedPath: points)
        let polyline = GMSPolyline(path: path)

        // Set the color and width for the polyline
        polyline.strokeColor = .blue
        polyline.strokeWidth = 5.0

        // Assign the polyline to the map
        polyline.map = mapView
    }
}

// MARK: - CLLocationManagerDelegate
extension KMapViewRepresentable: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: 15.0)
        mapView.animate(with: cameraUpdate)

        if showCurrentLocation {
            addCurrentLocationMarker()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}
