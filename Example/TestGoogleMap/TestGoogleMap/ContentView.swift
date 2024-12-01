//
//  ContentView.swift
//  TestGoogleMap
//
//  Created by Michelle Raouf on 30/11/2024.
//

import SwiftUI
import KGoogleMap
import GoogleMaps

struct ContentView: View {

    var body: some View {
        VStack {
            Text("Google Maps in SwiftUI")
                .font(.title)
            
            // Initialize and display the KMapViewWrapper
           KMapViewWrapper(camera: GMSCameraPosition.camera(withLatitude: 30.08167, longitude: 31.248462, zoom: 15),
                            markers: [],
                            showCurrentLocation: true)
            .frame(height: 300)
            .edgesIgnoringSafeArea(.all)
            

            Button(action: {
                // Safely unwrap and call getCurrentLocationData
                if let coordinator = KMapViewWrapper.Coordinator.shared {
                                   coordinator.showSearch()
                               }
                
            }) {
                Text("Get Current Location")
                    .padding()
                    .background(Color.blue)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}


struct KMapViewWrapper: UIViewRepresentable {
    var camera: GMSCameraPosition?
    var markers: [MarkerData]?
    var showCurrentLocation: Bool

    class Coordinator {
        static var shared: Coordinator?

        var mapView: KMapView?

        init(mapView: KMapView?) {
            self.mapView = mapView
            Coordinator.shared = self
        }

        func showSearch() {
            guard let mapView = mapView else { return }
                
            mapView.showSearch()
            
        }
        
        func setListnerAddress(listener: @escaping (LocationData) -> Void){
            mapView?.setListenerSelectedLocation { v in
                listener(v)
            }
        }
    }

    func makeUIView(context: Context) -> KMapView {
        let mapView = KMapView(camera: camera, markers: markers, showCurrentLocation: showCurrentLocation)
        context.coordinator.mapView = mapView
        return mapView
    }

    func updateUIView(_ uiView: KMapView, context: Context) {
        // Update the view with new data if necessary.
        if let updatedMarkers = markers {
            uiView.updateMarkers(updatedMarkers)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(mapView: nil)
    }
}
