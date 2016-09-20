import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locMgr: CLLocationManager?

    let appleHQ = Waypoint(
        name: "Apple",
        loc: CLLocation(latitude: 37.331843, longitude: -122.029574),
        color: .orangeColor()
    )

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        startListeningForLocation()
        return true
    }
    
    func startListeningForLocation() {
        locMgr = CLLocationManager()
        locMgr?.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined {
            locMgr?.requestWhenInUseAuthorization()
        } else {
            startMonitoring(status)
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        startMonitoring(status)
    }
    
    func startMonitoring(status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            locMgr?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locMgr?.startUpdatingLocation()
            print("Location services started")
        } else {
            print("Location permission denied")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("New location: \(newLocation)")
        print("Angle to Apple HQ: \(NavHelpers.haversine(from: newLocation, to: appleHQ.loc))")
    }
    
}
