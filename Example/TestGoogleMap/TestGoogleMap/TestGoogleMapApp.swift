//
//  TestGoogleMapApp.swift
//  TestGoogleMap
//
//  Created by Michelle Raouf on 30/11/2024.
//

import SwiftUI
import KGoogleMap

@main
struct TestGoogleMapApp: App {
    
     init(){
         KGoogleMapInit.provideAPIKey(key: "AIzaSyCfDTGDYO4-EngFi8_89J3QalqSGnPeQCg" )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
