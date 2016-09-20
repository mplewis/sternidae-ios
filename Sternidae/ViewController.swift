import UIKit
import CoreLocation
import SwiftEventBus

class ViewController: UIViewController {

    @IBOutlet weak var compass: CompassView!
    var pointer: PointerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        pointer = compass.newPointer()
        
        SwiftEventBus.onMainThread(self, name: "NewVector") { event in
            guard let vector = event.object as? Vector else {
                print("Invalid vector posted: \(event.object)")
                return
            }
            self.pointer?.setAngle(degrees: vector.course)
        }
    }

    @IBAction func onSliderChanged(sender: UISlider) {
        pointer?.length = CGFloat(sender.value)
        pointer?.setAngle(degrees: Double(sender.value * 360 - 90))
    }
}
