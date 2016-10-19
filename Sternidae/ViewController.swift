import UIKit
import CoreLocation
import ReactiveSwift

class ViewController: UIViewController {
    
    // MARK: - Constants

    let MPH_PER_MPS = 2.23694
    let MI_PER_M = 0.000621371
    
    let sampleWindow = 5
    let noEta = "-:--"
    
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
        let location = locSignal.map { $0.loc }
        let heading = sampler.map { NavHelpers.haversine(from: $0.first!.loc, to: $0.last!.loc) }
        let speed = sampler.map { self.speedOver(locs: $0) }
        let etaToDest = sampler.map { self.etaOver(locs: $0) }.filter { $0 != nil }.map { $0! }
        
        heading
            .map { NavHelpers.headingToCardinal(degrees: $0) }
            .observe { event in
                if let h = event.value {
                    self.headingView.value = h
                }
            }
        
        speed
            .map { "\(Int($0 * self.MPH_PER_MPS)) mph" }
            .observe { event in
                if let s = event.value {
                    self.speedView.value = s
                }
            }
        
        etaToDest
            .map { self.minSecs(seconds: $0) }
            .observe { event in
                if let e = event.value {
                    self.etaView.value = e
                }
            }

        location.combineLatest(with: heading).combineLatest(with: speed).observe { event in
            self.setPointerLengths()  // HACK
            if let ((location, heading), speed) = event.value {
                self.renderPointers(location: location, heading: heading)
                self.renderDestInfo(location: location, heading: heading, speed: speed)
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
    
    func etaOver(locs: [LocTime]) -> TimeInterval? {
        guard let first = locs.first, let last = locs.last else { return nil }
        
        let firstDist = first.loc.distance(from: currentDest.loc)
        let lastDist = last.loc.distance(from: currentDest.loc)
        let elapsed = last.time.timeIntervalSince(first.time)
        let mpsToward = (lastDist - firstDist) / elapsed
        let seconds = -lastDist / mpsToward
        return seconds
    }
    
    func minSecs(seconds: TimeInterval) -> String {
        if seconds < 0 {
            return noEta
        }

        let secs = Int(seconds.truncatingRemainder(dividingBy: 60))
        let mins = Int(seconds / 60)
        return String(format: "%d:%02d", mins, secs)
    }
    
    // MARK: Rendering
    
    func renderPointers(location: CLLocation, heading: CLLocationDegrees) {
        northPointer?.setAngle(degrees: -heading)
        for (waypoint, pointer) in zip(MockData.waypoints, waypointPointers) {
            let courseTo = NavHelpers.haversine(from: location, to: waypoint.loc)
            let displayCourse = courseTo - heading
            pointer.setAngle(degrees: displayCourse)
        }
    }
    
    func renderDestInfo(location: CLLocation, heading: CLLocationDegrees, speed: CLLocationSpeed) {
        let distance = String(format: "%.01f mi", location.distance(from: currentDest.loc) * MI_PER_M)
        let degrees = NavHelpers.haversine(from: location, to: currentDest.loc)
        let direction = NavHelpers.headingToCardinal(degrees: degrees)
        
        directionView.value = direction
        distanceView.value = distance
    }

}
