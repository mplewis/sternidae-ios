import UIKit
import CoreLocation
import ReactiveSwift

class ViewController: UIViewController {

    @IBOutlet weak var navInfo: UILabel!
    @IBOutlet weak var compass: CompassView!

    let sampleWindow = 5

    var northPointer: PointerView?
    var waypointPointers: [PointerView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        initPointers()
        listenForLocation()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func initPointers() {
        let np = compass.newPointer()
        np.color = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        northPointer = np

        for waypoint in MockData.waypoints {
            let pointer = compass.newPointer()
            pointer.color = waypoint.color
            waypointPointers.append(pointer)
        }
        
        setPointerLengths()
    }
    
    func setPointerLengths() {
        northPointer?.length = 0.6
        for pointer in waypointPointers {
            pointer.length = 0.2
        }
    }
    
    func listenForLocation() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let locSignal = appDelegate.locSignal else {
            print("locSignal not ready; couldn't observe location")
            return
        }

        let sampler = ReactiveHelpers.rollingWindow(signal: locSignal, count: sampleWindow)
        let location = sampler.map { $0.last!.loc }
        let heading = sampler.map { NavHelpers.haversine(from: $0.first!.loc, to: $0.last!.loc) }
        let speed = sampler.map { self.speedOver(locs: $0) }

        location.combineLatest(with: heading).combineLatest(with: speed).observe { event in
            self.setPointerLengths()  // HACK
            if let ((location, heading), speed) = event.value {
                self.render(location: location, heading: heading, speed: speed)
            }
        }
    }
    
    func distanceOver(locs: [LocTime]) -> CLLocationDistance {
        var dist: CLLocationDistance = 0
        for i in 0..<locs.count - 1 {
            let from = locs[i].loc
            let to = locs[i + 1].loc
            dist += to.distance(from: from)
        }
        return dist
    }
    
    func speedOver(locs: [LocTime]) -> CLLocationSpeed {
        let dist = distanceOver(locs: locs)
        let time = locs.last!.time.timeIntervalSince(locs.first!.time)
        return dist / time
    }
    
    func render(location: CLLocation, heading: CLLocationDegrees, speed: CLLocationSpeed) {
        renderPointers(location: location, heading: heading)
        renderInfo(location: location, heading: heading, speed: speed)
    }
    
    func renderPointers(location: CLLocation, heading: CLLocationDegrees) {
        northPointer?.setAngle(degrees: -heading)
        for (waypoint, pointer) in zip(MockData.waypoints, waypointPointers) {
            let courseTo = NavHelpers.haversine(from: location, to: waypoint.loc)
            let displayCourse = courseTo - heading
            pointer.setAngle(degrees: displayCourse)
        }
    }
    
    func renderInfo(location: CLLocation, heading: CLLocationDegrees, speed: CLLocationSpeed) {
        let MPH_PER_MPS = 2.23694
        let MI_PER_M = 0.000621371
        
        let mph = String(format: "%.01f", speed * MPH_PER_MPS)
        var info = [
            "Heading: \(NavHelpers.headingToCardinal(degrees: heading))",
            "Speed: \(mph) mph",
        ]

        MockData.waypoints.forEach { waypoint in
            let name = waypoint.name
            let distance = String(format: "%.01f", location.distance(from: waypoint.loc) * MI_PER_M)
            let degrees = NavHelpers.haversine(from: location, to: waypoint.loc)
            let direction = NavHelpers.headingToCardinal(degrees: degrees)
            info.append("\(name): \(distance) mi \(direction)")
        }
        
        let output = info.joined(separator: "\n")
        navInfo.text = output
    }

}
