import CoreLocation

public class LocationListener: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager
    private var locationUpdateHandler: ((CLLocation) -> Void)?
    private var lastUpdateTimestamp: Date?
    private let updateDelay: TimeInterval = 1.0 // Delay in seconds (1 second)

    public override init() {
        self.locationManager = CLLocationManager()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        print("LocationManager initialized and started.")
    }
    
    public func setLocationUpdateHandler(_ handler: @escaping (CLLocation) -> Void) {
        self.locationUpdateHandler = handler
        print("Location update handler set.")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did update locations called.")
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
