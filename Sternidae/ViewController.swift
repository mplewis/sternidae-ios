import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var compass: CompassView!
    var pointer: PointerView?

    override func viewDidLoad() {
        super.viewDidLoad()
        pointer = compass.newPointer()
    }

    @IBAction func onSliderChanged(sender: UISlider) {
        pointer?.length = CGFloat(sender.value)
        pointer?.setAngle(degrees: Double(sender.value * 360 - 90))
    }
}
