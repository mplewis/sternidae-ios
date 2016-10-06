import UIKit
import CoreLocation

class LocTime: CustomStringConvertible {
    let loc: CLLocation
    let time: Date
    
    var description: String {
        let lat = loc.coordinate.latitude
        let lng = loc.coordinate.longitude
        return "(\(lat), \(lng)) at \(time)"
    }

    convenience init(loc: CLLocation) {
        self.init(loc: loc, time: Date())
    }
    
    init(loc: CLLocation, time: Date) {
        self.loc = loc
        self.time = time
    }
}
