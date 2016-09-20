import UIKit
import CoreLocation

class Waypoint: NSObject {
    
    let name: String
    let loc: CLLocation
    let color: UIColor
    
    init(name: String, loc: CLLocation, color: UIColor) {
        self.name = name
        self.loc = loc
        self.color = color
    }

}
