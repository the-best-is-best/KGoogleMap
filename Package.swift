// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "KGoogleMap",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "KGoogleMap",
            targets: ["KGoogleMap"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/googlemaps/ios-maps-sdk.git", from: "9.2.0"),
        .package(url: "https://github.com/googlemaps/ios-places-sdk.git", from: "9.2.0"),
        .package(url: "https://github.com/googlemaps/google-maps-ios-utils.git", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "KGoogleMap",
            dependencies: [
                .product(name: "GoogleMaps", package: "ios-maps-sdk"),
                .product(name: "GooglePlaces", package: "ios-places-sdk"),
                .product(name: "GoogleMapsUtils", package: "google-maps-ios-utils")
            ]
        ),
        .testTarget(
            name: "KGoogleMapTests",
            dependencies: ["KGoogleMap"]
        ),
    ]
)
