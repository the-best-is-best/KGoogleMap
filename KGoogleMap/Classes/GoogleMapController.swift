
import UIKit
import GoogleMaps

@objc class ViewController: UIViewController {
    var camera: GMSCameraPosition
    var markers: [MarkerData] = [
         
       ]
    init(camera: GMSCameraPosition, markers: [MarkerData] = []) {
           self.camera = camera
           self.markers = markers
           super.init(nibName: nil, bundle: nil)
       }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.

        let options = GMSMapViewOptions()
        options.camera = camera
        options.frame = self.view.bounds

        let mapView = GMSMapView(options: options)
        self.view.addSubview(mapView)

        addMarkers(to: mapView)
  }
    
    private func addMarkers(to mapView: GMSMapView) {
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
}
