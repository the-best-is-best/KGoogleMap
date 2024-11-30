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
    // Create a state variable to store the KMapViewWrapper instance

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
                Task {
                    if let locationData = await KMapViewWrapper.Coordinator(mapView: KMapView()).searchAddress(query: "St Teresa Catholic Church") {
                        print("Current location data: \(locationData.name)")
                    } else {
                        print("Failed to get current location data.")
                    }
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
        var mapView: KMapView?
        
        init(mapView: KMapView?) {
            self.mapView = mapView
        }
        
        func searchAddress(query: String)  async -> LocationData? {
            return  await mapView?.searchAddress(searchString: query)
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
