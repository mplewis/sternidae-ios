import UIKit
import CoreLocation
import SwiftEventBus

class ViewController: UIViewController {

    @IBOutlet weak var compass: CompassView!
    var pointer: PointerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        pointer = compass.newPointer()
        
        SwiftEventBus.onMainThread(self, name: "NewLocation") { event in
            guard let current = event.object as? CLLocation else {
                print("Invalid location posted: \(event.object)")
                return
            }
            let degrees = NavHelpers.haversine(from: current, to: MockData.appleHQ.loc)
            self.pointer?.setAngle(degrees: degrees)
        }
    }

    @IBAction func onSliderChanged(sender: UISlider) {
        pointer?.length = CGFloat(sender.value)
        pointer?.setAngle(degrees: Double(sender.value * 360 - 90))
    }
}
