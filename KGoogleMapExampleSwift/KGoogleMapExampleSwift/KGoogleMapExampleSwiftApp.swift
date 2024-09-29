//
//  KGoogleMapExampleSwiftApp.swift
//  KGoogleMapExampleSwift
//
//  Created by Michelle Raouf on 29/09/2024.
//

import SwiftUI
import KGoogleMap
import CoreLocation
@main
struct KGoogleMapExampleSwiftApp: App {
    init() {
        KGoogleMapInit.provideAPIKey(key: "AIzaSyCF7KfFT1hqtVyfX4XQira2QPGZ9uxpclk")
    }
    var body: some Scene {
        WindowGroup {
            VStack {
                MapView(totalDistance: .constant(0))
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}
