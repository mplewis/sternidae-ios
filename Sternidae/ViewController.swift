import UIKit
import CoreLocation
import ReactiveSwift

class ViewController: UIViewController {
    
    // MARK: - Constants

    let MPH_PER_MPS = 2.23694
    let MI_PER_M = 0.000621371

    // MARK: - IB Outlets

    @IBOutlet weak var headingView: NavInfoView!
    @IBOutlet weak var speedView: NavInfoView!
    
    @IBOutlet weak var destinationView: UILabel!
    @IBOutlet weak var directionView: NavInfoView!
    @IBOutlet weak var distanceView: NavInfoView!
    @IBOutlet weak var etaView: NavInfoView!

    @IBOutlet weak var compass: CompassView!
    
    // MARK: IB Actions
    
    @IBAction func prevDestination(_ sender: UIButton) {
        currentDestIndex -= 1
    }
    
    @IBAction func nextDestination(_ sender: UIButton) {
        currentDestIndex += 1
    }
    
    // MARK: - Variables
    
    var sampleWindow: Int = 5

    var northPointer: PointerView?
    var waypointPointers: [PointerView] = []
    
    var _cdi = 0
    var currentDestIndex: Int {
        get {
            return _cdi
        }
        set(new) {
            _cdi = (new + MockData.waypoints.count) % MockData.waypoints.count
            destinationView.text = currentDest.name
            destinationView.textColor = currentDest.color
        }
    }
    
    var currentDest: Waypoint {
        return MockData.waypoints[currentDestIndex]
    }
    
    // MARK: - UIView methods
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        initPointers()
        currentDestIndex = 0
        listenForLocation(samples: sampleWindow)
    }
    
    // MARK: Setup
    
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
    
    // MARK: - Handle incoming location
    
    func listenForLocation(samples: Int) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let locSignal = appDelegate.locSignal else {
            print("locSignal not ready; couldn't observe location")
            return
        }

        let sampler = ReactiveHelpers.rollingWindow(signal: locSignal, count: samples)
        let location = sampler.map { $0.last!.loc }
        let heading = sampler.map { NavHelpers.haversine(from: $0.first!.loc, to: $0.last!.loc) }
        let speed = sampler.map { self.speedOver(locs: $0) }
        
        heading.observe { event in
            if let h = event.value {
                self.headingView.value = NavHelpers.headingToCardinal(degrees: h)
            }
        }
        
        speed.observe { event in
            if let s = event.value {
                self.speedView.value = "\(Int(s * self.MPH_PER_MPS)) mph"
            }
        }

        location.combineLatest(with: heading).combineLatest(with: speed).observe { event in
            self.setPointerLengths()  // HACK
            if let ((location, heading), speed) = event.value {
                self.render(location: location, heading: heading, speed: speed)
            }
        }
    }
    
    // MARK: Processing helpers
    
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
    
    // MARK: Rendering
    
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
        let distance = String(format: "%.01f mi", location.distance(from: currentDest.loc) * MI_PER_M)
        let degrees = NavHelpers.haversine(from: location, to: currentDest.loc)
        let direction = NavHelpers.headingToCardinal(degrees: degrees)
        
        directionView.value = direction
        distanceView.value = distance
        etaView.value = "-:--"
    }

}
