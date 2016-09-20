import UIKit
import CoreLocation

class NavHelpers {
    /**
     - parameter degrees: an angle in degrees
     - returns: the angle converted to radians
     */
    class func degreesToRadians(_ degrees: CLLocationDegrees) -> Double { return degrees * M_PI / 180.0 }

    /**
     - parameter radians: an angle in radians
     - returns: the angle converted to degrees
     */
    class func radiansToDegrees(_ radians: Double) -> CLLocationDegrees { return radians * 180.0 / M_PI }
    
    /**
     Gets the bearing between two points using the Haversine function.
     
     - parameter from: the origin
     - parameter to: the destination
     
     - returns: the angle between `from` and `to`, in radians
     */
    class func haversine(from: CLLocation, to: CLLocation) -> CLLocationDegrees {
        let lat1 = degreesToRadians(from.coordinate.latitude)
        let lon1 = degreesToRadians(from.coordinate.longitude)
        
        let lat2 = degreesToRadians(to.coordinate.latitude)
        let lon2 = degreesToRadians(to.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var radiansBearing = atan2(y, x)
        if radiansBearing < 0 {
            radiansBearing += 2 * M_PI
        }
        
        return radiansToDegrees(radiansBearing)
    }
}
