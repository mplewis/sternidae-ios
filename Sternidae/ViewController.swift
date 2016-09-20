import UIKit
import CoreLocation
import SwiftEventBus

class ViewController: UIViewController {

    @IBOutlet weak var compass: CompassView!
    var northPointer: PointerView?
    var waypointPointers: [PointerView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initPointers()
        watchEventBus()
    }
    
    func initPointers() {
        let np = compass.newPointer()
        np.length = 0.6
        np.color = .redColor()
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
        }
    }
    
    func renderPointers(current: Vector) {
        let myCourse = current.course
        northPointer?.setAngle(degrees: -myCourse)
        for (waypoint, pointer) in zip(MockData.waypoints, waypointPointers) {
            let courseTo = NavHelpers.haversine(from: current.loc, to: waypoint.loc)
            let displayCourse = courseTo - myCourse
            pointer.setAngle(degrees: displayCourse)
        }
    }

}
