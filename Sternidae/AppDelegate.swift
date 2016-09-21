import UIKit
import CoreLocation
import SwiftEventBus
import ReactiveSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locMgr: CLLocationManager?
    var lastVector: Vector?
    
    enum NoError: Error { case dontCare }
    var locObserver: Observer<CLLocation, NoError>?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        startListeningForLocation()
        
        let (locSignal, lObs) = Signal<CLLocation, NoError>.pipe()
        locObserver = lObs

        locSignal.observe { event in
            if let val = event.value {
                print("Observed location change: \(val)")
            }
        }
        return true
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
            locObserver?.send(value: location)
        }
    }
    
}
