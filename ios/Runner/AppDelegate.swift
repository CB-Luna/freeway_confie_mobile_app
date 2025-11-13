import Flutter
import UIKit
import GoogleMaps
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    // Configure Google Maps
    GMSServices.provideAPIKey("AIzaSyB6C-S87hsklhvinf5X1czu3xdz52s2bBc")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
