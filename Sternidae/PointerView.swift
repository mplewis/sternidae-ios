import UIKit
import CoreLocation

@IBDesignable class PointerView: UIView {
    
    @IBInspectable var color: UIColor = .whiteColor()
    @IBInspectable var thickness: CGFloat = 5
    @IBInspectable var outerGap: CGFloat = 0
    @IBInspectable var length: CGFloat = 1.0 {
        didSet {
            let fullLength = min(bounds.width, bounds.height) / 2 - outerGap
            innerGap = (1 - length) * fullLength
            setNeedsDisplay()
        }
    }
    
    private var innerGap: CGFloat = 0
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = thickness

        let (inner, outer) = innerOuterPoints()
        path.moveToPoint(inner)
        path.addLineToPoint(outer)

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
    
    func setAngle(degrees degrees: CLLocationDegrees) {
        let rads = NavHelpers.degreesToRadians(degrees)
        transform = CGAffineTransformMakeRotation(CGFloat(rads))
    }

}
