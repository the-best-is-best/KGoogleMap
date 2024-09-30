//
//  KMapView.swift
//  KGoogleMap
//
//  Created by Michelle Raouf on 29/09/2024.
//

import SwiftUI
import GoogleMaps

// UIView subclass to wrap KMapViewRepresentable
import UIKit
import GoogleMaps

@objc public class KMapView: UIView {
    private var mapViewController: KMapViewRepresentable?

    @objc public init(camera: GMSCameraPosition? = nil, markers: [MarkerData] = []) {
        super.init(frame: .zero)
        setupMapView(camera: camera, markers: markers)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupMapView(camera: GMSCameraPosition?, markers: [MarkerData]) {
        mapViewController = KMapViewRepresentable(camera: camera, markers: markers)
        
        guard let mapViewController = mapViewController else { return }

        // Embed the mapViewController's view into the KMapView
        mapViewController.view.frame = self.bounds
        mapViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(mapViewController.view)

        // Optionally, attach the view controller to a parent view controller
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
}
