import UIKit
import CoreLocation

@IBDesignable class PointerView: UIView {
    
    @IBInspectable var color: UIColor = .white
    @IBInspectable var thickness: CGFloat = 5
    @IBInspectable var outerGap: CGFloat = 0
    @IBInspectable var length: CGFloat = 1.0 {
        didSet {
            let fullLength = min(bounds.width, bounds.height) / 2 - outerGap
            innerGap = (1 - length) * fullLength
            setNeedsDisplay()
        }
    }
    
    fileprivate var innerGap: CGFloat = 0
    fileprivate var angleSet = false
    
    override func draw(_ rect: CGRect) {
        // Don't draw this until the angle has been set for the first time
        if !angleSet { return }

        let path = UIBezierPath()
        path.lineWidth = thickness

        let (inner, outer) = innerOuterPoints()
        path.move(to: inner)
        path.addLine(to: outer)

        color.setStroke()
        path.stroke()
    }
    
    func innerOuterPoints() -> (inner: CGPoint, outer: CGPoint) {
        let rads: CGFloat = 0
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let innerDist = innerGap
        let outerDist = min(bounds.width, bounds.height) / 2 - outerGap
        
        let innerX = center.x + cos(rads) * innerDist
        let outerX = center.x + cos(rads) * outerDist
        let innerY = center.y - sin(rads) * innerDist
        let outerY = center.y - sin(rads) * outerDist
        let inner = CGPoint(x: innerX, y: innerY)
        let outer = CGPoint(x: outerX, y: outerY)
        
        return (inner, outer)
    }
    
    /**
     Sets the angle of the pointer.
     
     - parameter degrees: the angle to set the pointer to, in compass degrees. 0 = N, 90 = E
     */
    func setAngle(degrees: CLLocationDegrees) {
        let unitCircleDegrees = degrees - 90
        let rads = NavHelpers.degreesToRadians(unitCircleDegrees)
        transform = CGAffineTransform(rotationAngle: CGFloat(rads))
        angleSet = true
    }

}
