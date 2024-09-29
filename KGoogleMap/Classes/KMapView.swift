//
//  KMapView.swift
//  KGoogleMap
//
//  Created by Michelle Raouf on 29/09/2024.
//

import SwiftUI
import GoogleMaps

// UIView subclass to wrap KMapViewRepresentable
@objc public class KMapView: UIView {
    // Property for total distance
    private var _totalDistance: CLLocationDistance

    // Public property for total distance, exposing it for Objective-C
    @objc public var totalDistance: CLLocationDistance {
        get { _totalDistance }
        set { _totalDistance = newValue }
    }

    // Initializer accepting CLLocationDistance
    @objc public init(totalDistance: CLLocationDistance) {
        self._totalDistance = totalDistance
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Create a Binding to use in the representable
        let totalDistanceBinding = Binding<CLLocationDistance>(
            get: { self._totalDistance },
            set: { self._totalDistance = $0 }
        )

        let representable = KMapViewRepresentable(totalDistance: totalDistanceBinding)
        let swiftUIController = UIHostingController(rootView: representable)
        swiftUIController.view.frame = bounds
        swiftUIController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(swiftUIController.view)
    }
}
