import SwiftUI
import GoogleMaps
import CoreLocation

public struct KMapView: UIViewRepresentable {
    // Binding for total distance
    @Binding var totalDistance: CLLocationDistance

    // Coordinator to handle events
    public class Coordinator: NSObject, CLLocationManagerDelegate {
        var mapView: GMSMapView?
        var locationManager = CLLocationManager()
        var previousLocation: CLLocation?
        var polyline: GMSPolyline?
        @Binding var totalDistance: CLLocationDistance

        init(totalDistance: Binding<CLLocationDistance>) {
            self._totalDistance = totalDistance
            super.init()
            
            // Set up the location manager
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }

        // Location manager delegate method
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.first else { return }

            // Calculate distance and update total distance
            if let previousLocation = self.previousLocation {
                let distance = location.distance(from: previousLocation)
                self.totalDistance += distance
            }

            // Update polyline to draw the route
            if let path = polyline?.path {
                let mutablePath = GMSMutablePath(path: path)
                mutablePath.add(location.coordinate)
                polyline?.path = mutablePath
            } else {
                let path = GMSMutablePath()
                path.add(location.coordinate)
                
                let newPolyline = GMSPolyline(path: path)
                newPolyline.strokeColor = .red
                newPolyline.strokeWidth = 5.0
                newPolyline.map = mapView
                polyline = newPolyline
            }

            // Set camera position to current location
            let zoom: Float = 18.0
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: zoom)
            mapView?.animate(to: camera)

            self.previousLocation = location
        }

        // Authorization status change handler
        public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationManager.startUpdatingLocation()
                mapView?.isMyLocationEnabled = true
                mapView?.settings.myLocationButton = true
            } else {
                // Handle authorization denied state if needed
                locationManager.stopUpdatingLocation()
            }
        }

        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location Manager failed with error: \(error.localizedDescription)")
        }
    }

    // Make coordinator
    public func makeCoordinator() -> Coordinator {
        return Coordinator(totalDistance: $totalDistance)
    }

    // Make UIView
    public func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        
        // Set coordinator's mapView
        context.coordinator.mapView = mapView

        // Request location authorization and start updating location
        context.coordinator.locationManager.requestWhenInUseAuthorization()
        context.coordinator.locationManager.startUpdatingLocation()
        
        return mapView
    }

    public func updateUIView(_ uiView: GMSMapView, context: Context) {}

    // Explicitly make the initializer public
    public init(totalDistance: Binding<CLLocationDistance>) {
        self._totalDistance = totalDistance
    }
}
