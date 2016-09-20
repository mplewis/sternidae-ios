import UIKit
import CoreLocation
import SwiftEventBus

class ViewController: UIViewController {

    @IBOutlet weak var navInfo: UILabel!
    @IBOutlet weak var compass: CompassView!

    var northPointer: PointerView?
    var waypointPointers: [PointerView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        initPointers()
        watchEventBus()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func initPointers() {
        let np = compass.newPointer()
        np.length = 0.6
        np.color = UIColor(red:0.91, green:0.30, blue:0.24, alpha:1.0)
        northPointer = np

        for waypoint in MockData.waypoints {
            let pointer = compass.newPointer()
            pointer.length = 0.15
            pointer.color = waypoint.color
            waypointPointers.append(pointer)
        }
    }
    
    func watchEventBus() {
        SwiftEventBus.onMainThread(self, name: "NewVector") { event in
            guard let vector = event.object as? Vector else {
                print("Invalid vector posted: \(event.object)")
                return
            }
            self.renderPointers(vector)
            self.renderNavInfo(vector)
        }
    }
    
    func renderPointers(_ current: Vector) {
        let myCourse = current.course
        northPointer?.setAngle(degrees: -myCourse)
        for (waypoint, pointer) in zip(MockData.waypoints, waypointPointers) {
            let courseTo = NavHelpers.haversine(from: current.loc, to: waypoint.loc)
            let displayCourse = courseTo - myCourse
            pointer.setAngle(degrees: displayCourse)
        }
    }
    
    func renderNavInfo(_ current: Vector) {
        let MPH_PER_MPS = 2.23694
        let MI_PER_M = 0.000621371

        let mph = String(format: "%.01f", current.speed * MPH_PER_MPS)
        var info = [
            "Heading: \(Int(current.course))°",
            "Speed: \(mph) mph",
        ]

        MockData.waypoints.map { (waypoint) -> (String, UIColor, CLLocationDistance) in
            return (waypoint.name, waypoint.color, current.loc.distance(from: waypoint.loc))
        }.forEach { (name, color, meters) in
            let mi = String(format: "%.01f", meters * MI_PER_M)
            info.append("\(name): \(mi) mi")
        }
        
        let output = info.joined(separator: "\n")
        navInfo.text = output
    }

}
