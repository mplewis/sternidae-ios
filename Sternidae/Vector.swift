import UIKit
import CoreLocation

/// A position with speed and course since the last point visited. Speed and course are only valid if `valid` is true.
class Vector: CustomStringConvertible {
    
    let loc: CLLocation
    let time: NSDate
    let speed: CLLocationSpeed
    let course: CLLocationDirection
    let valid: Bool

    var description: String {
        if valid {
            return "\(loc) (\(speed) m/s, \(course)°)"
        } else {
            return "\(loc) (no speed or course data)"
        }
    }
    
    /**
     Create a Vector with a location, a timestamp, and the last vector visited.
     
     - parameter loc:  The current location
     - parameter time: The time at which this location was observed
     - parameter last: The last location vector
     
     - returns: A Vector with a valid speed and course
     */
    init(loc: CLLocation, time: NSDate, last: Vector) {
        let dist = loc.distanceFromLocation(last.loc)
        let since = time.timeIntervalSinceDate(last.time)
        self.loc = loc
        self.time = time
        self.speed = dist / since
        self.course = NavHelpers.haversine(from: last.loc, to: loc)
        self.valid = true
    }
    
    /**
     Create the first Vector when no other vector is available.
     
     - parameter loc:  The current location
     - parameter time: The time at which this location was observed
     
     - returns: A Vector with no valid speed and course
     */
    init(loc: CLLocation, time: NSDate) {
        self.loc = loc
        self.time = time
        self.speed = -1
        self.course = -1
        self.valid = false
    }
    
}
