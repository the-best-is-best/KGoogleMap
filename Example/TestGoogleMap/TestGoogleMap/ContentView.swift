//
//  ContentView.swift
//  TestGoogleMap
//
//  Created by Michelle Raouf on 30/11/2024.
//

import SwiftUI
import KGoogleMap
import GoogleMaps
import CoreLocation

struct ContentView: View {


    var body: some View {
        VStack {
            Text("Google Maps in SwiftUI")
                .font(.title)

            // Initialize and display the KMapViewWrapper
            KMapViewWrapper(
                            markers: [],
                            showCurrentLocation: true)
                .frame(height: 300)
                .ignoresSafeArea()

            Button(action: {
                // Optional action when button is clicked
                print("Button clicked")
            }) {
                Text("Get Current Location")
                    .padding()
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
    var markers: [MarkerData]?
    var showCurrentLocation: Bool

    class Coordinator {
        static var shared: Coordinator?

        var mapView: KMapView?

        init(mapView: KMapView?) {
              self.mapView = mapView
            
              Coordinator.shared = self
              // Set up listeners only when mapView is fully initialized
                  mapView?.setClickListener(listener: { locationData in
                      print("Clicked location: \(locationData)")
                  })
                  mapView?.setLongClickListener(listener: { locationData in
                      print("Long clicked location: \(locationData)")
                  })
              
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
        let mapView = KMapView(markers: markers, showCurrentLocation: showCurrentLocation) {
            print("map loaded")
        }
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
