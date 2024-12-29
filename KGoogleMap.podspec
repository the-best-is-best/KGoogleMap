#
# Be sure to run `pod lib lint KGoogleMap.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KGoogleMap'
  s.version          = '0.1.4'  # Use rc or beta versioning as needed
  s.summary          = 'A library for integrating Google Maps with CocoaPods Kotlin Multiplatform'
  s.description      = 'KGoogleMap is a support controller for Google Maps to use it with Kotlin Multiplatform.'

  s.homepage         = 'https://github.com/the-best-is-best/KGoogleMap'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'the-best-is-best' => 'michelle.raouf@outlook.com' }
  s.source           = { :git => 'https://github.com/the-best-is-best/KGoogleMap.git', :tag => s.version.to_s }

  # Specify the deployment target for iOS
  s.ios.deployment_target = '15'
  s.swift_version    = '5.5'

  # Specify the source files for the KMM library
  s.source_files = 'KGoogleMap/Classes/**/*'

  # Specify the dependencies
  s.dependency 'GoogleMaps', '9.2.0'  # Google Maps SDK for iOS
  s.dependency 'Google-Maps-iOS-Utils' , '6.0.0'
  s.dependency 'GooglePlaces' , '9.2.0'


  s.static_framework = true


end
