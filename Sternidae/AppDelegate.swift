import UIKit
import CoreLocation
import SwiftEventBus

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locMgr: CLLocationManager?
    var lastVector: Vector?

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
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation,
                         fromLocation oldLocation: CLLocation) {
        guard let last = lastVector else {
            lastVector = Vector(loc: newLocation, time: NSDate())
            return
        }
        let current = Vector(loc: newLocation, time: NSDate(), last: last)
        print(current)
        SwiftEventBus.post("NewVector", sender: current)
        lastVector = current
    }
    
}
