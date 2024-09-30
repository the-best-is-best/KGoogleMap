import SwiftUI
import GoogleMaps
import CoreLocation

public class KMapViewRepresentable: UIViewController, CLLocationManagerDelegate {
    var camera: GMSCameraPosition?
    var markers: [MarkerData] = []
    
    private var locationManager: CLLocationManager = CLLocationManager()
    private var mapView: GMSMapView?

    init(camera: GMSCameraPosition? = nil, markers: [MarkerData] = []) {
        self.camera = camera
        self.markers = markers
        super.init(nibName: nil, bundle: nil)
        
        // Configure CLLocationManager
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        addMarkers(to: mapView)
    }
    
    private func setupMapView() {
        let options = GMSMapViewOptions()
        options.camera = camera
        options.frame = self.view.bounds
        
        mapView = GMSMapView(options: options)
        mapView?.frame = self.view.bounds
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let mapView = mapView {
            self.view.addSubview(mapView)
        }
        
        if camera == nil {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func addMarkers(to mapView: GMSMapView?) {
        guard let mapView = mapView else { return }
        
        for markerData in markers {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: markerData.latitude, longitude: markerData.longitude)
            marker.title = markerData.title
            marker.snippet = markerData.snippet
            
            // Set a custom icon if provided
            if let icon = markerData.icon {
                marker.icon = icon
            }
            
            marker.map = mapView
        }
    }
    
    // CLLocationManagerDelegate method to update the location
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            camera = GMSCameraPosition.camera(withTarget: userLocation, zoom: 15)
            
            // Move the camera to the user's location
            mapView?.camera = camera!
            locationManager.stopUpdatingLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error retrieving location: \(error.localizedDescription)")
    }
}
