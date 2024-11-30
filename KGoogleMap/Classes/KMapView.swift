// KMapView.swift
// KGoogleMap
//
// Created by Michelle Raouf on 29/09/2024.
import SwiftUI
import GoogleMaps
import UIKit

@objc public class KMapView: UIView {
    private var mapViewController: KMapViewRepresentable?

    @objc public init(camera: GMSCameraPosition? = nil,
                     markers: [MarkerData]? = nil, // Allow markers to be nil
                      showCurrentLocation: Bool = false) {
        super.init(frame: .zero)
        setupMapView(camera: camera,
                     markers: markers ?? [], // Provide an empty array if markers is nil
                     showCurrentLocation: showCurrentLocation)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupMapView(camera: GMSCameraPosition?,
                              markers: [MarkerData],
                              showCurrentLocation: Bool) {
        
        mapViewController = KMapViewRepresentable(camera: camera,
                                                  markers: markers,
                                                  showCurrentLocation: showCurrentLocation)
        
        guard let mapViewController = mapViewController else { return }

        mapViewController.view.frame = self.bounds
        mapViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(mapViewController.view)

        if let parentViewController = findViewController() {
            parentViewController.addChild(mapViewController)
            mapViewController.didMove(toParent: parentViewController)
        }
    }

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

    @objc public func updateMarkers(_ markers: [MarkerData]) {
        mapViewController?.markers = markers
        mapViewController?.addMarkers(to: mapViewController!.mapView!)
    }

    @objc public func renderRoad(_ points: String) {
        mapViewController?.renderRoad(points)
    }

    @objc public func clearMarkers() {
        mapViewController?.markers.removeAll()
        mapViewController?.mapView?.clear()
        mapViewController?.showUserLocation()
    }

    @objc public func zoomToLocation(_ location: CLLocationCoordinate2D, zoom: Float = 15.0) {
        let cameraUpdate = GMSCameraUpdate.setTarget(location, zoom: zoom)
        mapViewController?.mapView?.animate(with: cameraUpdate)
    }

    @objc public func resetCameraPosition() {
        if let initialCamera = mapViewController?.camera {
            mapViewController?.mapView?.animate(to: initialCamera)
        } else {
            if let currentLocation = mapViewController?.locationManager.location {
                let currentCoordinate = currentLocation.coordinate
                let cameraUpdate = GMSCameraUpdate.setTarget(currentCoordinate, zoom: 15.0)
                mapViewController?.mapView?.animate(with: cameraUpdate)
                print("Resetting camera to current location: \(currentCoordinate)")
            } else {
                print("Current location is not available to reset camera position.")
            }
        }
    }

    @objc public func setCameraPosition(_ cameraPosition: GMSCameraPosition) {
        mapViewController?.mapView?.camera = cameraPosition
    }

    @objc public func showUserLocation(_ show: Bool) {
        mapViewController?.showCurrentLocation = show
        mapViewController?.showUserLocation()
    }

    @objc public func setRouteVisibility(_ visible: Bool) {
        mapViewController?.setRouteVisibility(visible)
    }

    // Method to retrieve the current location data
    @objc public func showSearch() {
        mapViewController?.openPlaceSearch()
    }
    
    @objc public func setListenerSelectedLocation(listener: @escaping (LocationData) -> Void) {
        mapViewController?.didSelectLocation = listener
       }
    
}


func getCurrentViewController() -> UIViewController? {
    guard let keyWindow = UIApplication.shared.connectedScenes
        .filter({ $0.activationState == .foregroundActive })
        .compactMap({ $0 as? UIWindowScene })
        .first?.windows
        .first(where: { $0.isKeyWindow }) else {
        return nil
    }
    
    var topController = keyWindow.rootViewController
    
    while let presentedController = topController?.presentedViewController {
        topController = presentedController
    }
    
    if let navigationController = topController as? UINavigationController {
        topController = navigationController.visibleViewController
    }
    
    if let tabBarController = topController as? UITabBarController {
        topController = tabBarController.selectedViewController
    }
    
    return topController
}

