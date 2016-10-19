import UIKit
import CoreLocation

class MockData {
    
    static let waypoints = [
        Waypoint(
            name: "Home",
            loc: CLLocation(latitude: 39.729337, longitude: -104.927597),
            color: UIColor(red:1.00, green:0.81, blue:0.35, alpha:1.0)),
        Waypoint(
            name: "Work",
            loc: CLLocation(latitude: 39.753386, longitude: -104.991516),
            color: UIColor(red:0.39, green:0.84, blue:1.00, alpha:1.0)),
    ]

}
