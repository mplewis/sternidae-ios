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
     
     - returns: the angle between `from` and `to`, in degrees
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
    
    class func headingToCardinal(degrees: CLLocationDegrees) -> String {
        let cardinals = [
            "N", "NNE", "NE", "ENE",
            "E", "ESE", "SE", "SSE",
            "S", "SSW", "SW", "WSW",
            "W", "WNW", "NW", "NNW",
        ]
        
        let stepDegrees = 360 / cardinals.count
        
        var index = Int(degrees.truncatingRemainder(dividingBy: 360))
        if index < 0 {
            index += 360
        }
        index += stepDegrees / 2
        index /= stepDegrees

        return cardinals[index % cardinals.count]
    }
}
