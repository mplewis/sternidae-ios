import UIKit
import CoreLocation

class MockData {
    
    static let waypoints = [
        Waypoint(
            name: "Home",
            loc: CLLocation(latitude: 39.729337, longitude: -104.927597),
            color: UIColor(red:0.18, green:0.80, blue:0.44, alpha:1.0)),
        Waypoint(
            name: "Work",
            loc: CLLocation(latitude: 39.753386, longitude: -104.991516),
            color: UIColor(red:0.20, green:0.60, blue:0.86, alpha:1.0)),
    ]

}
