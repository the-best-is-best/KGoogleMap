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
         KGoogleMapInit.provideAPIKey(key: "AIzaSyDJxBZCH0AwJnUTg6R8zGDy2KmwVaKXkJk" )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
