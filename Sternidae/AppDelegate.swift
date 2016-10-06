import UIKit
import CoreLocation
import SwiftEventBus
import ReactiveSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locMgr: CLLocationManager?

    enum NoError: Error { case dontCare }
    var locSignal: Signal<LocTime, NoError>?
    var locObserver: Observer<LocTime, NoError>?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupSignal()
        startListeningForLocation()
        UIApplication.shared.isIdleTimerDisabled = true  // disable auto sleep
        return true
    }
    
    func setupSignal() {
        let (lSig, lObs) = Signal<LocTime, NoError>.pipe()
        locSignal = lSig
        locObserver = lObs
    }
    
    func startListeningForLocation() {
        locMgr = CLLocationManager()
        locMgr?.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            locMgr?.requestWhenInUseAuthorization()
        } else {
            startMonitoring(status)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        startMonitoring(status)
    }
    
    func startMonitoring(_ status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            locMgr?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locMgr?.startUpdatingLocation()
            print("Location services started")
        } else {
            print("Location permission denied")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            sendIfUpdated(location: location)
        }
    }
    
    /**
     Sends data from CoreLocation to the event stream, but only if there's an actual update.
     
     iOS likes to send the same location twice in a row with no delay. This is a hack to work around that.
     
     If the most recent point isn't far from the last point, don't send the update until there's a significant change.
     
     - parameter location: the new location to be sent, if it's not redundant
     */
    func sendIfUpdated(location: CLLocation) {
        let minDist: CLLocationDistance = 1  // minimum distance between points, in meters
        if isLocationUpdate(location, minDist: minDist) {
            locObserver?.send(value: LocTime(loc: location))
            lastLoc = location
        }
    }
    
    var lastLoc: CLLocation?
    /**
     Used to tell if a location is a duplicate of the most recent CoreLocation update.
     
     - parameter location: the most recent location from CoreLocation
     - parameter minDist: the minimum distance this must be from the last location to count as an update
     - returns: true if this is the first location, or the last location is far enough away from this location
     */
    func isLocationUpdate(_ location: CLLocation, minDist: CLLocationDistance) -> Bool {
        guard let last = lastLoc else { return true }
        return last.distance(from: location) > minDist
    }
    
}
