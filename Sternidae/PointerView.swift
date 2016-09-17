import UIKit

@IBDesignable class PointerView: UIView {
    
    @IBInspectable var color: UIColor = .whiteColor()
    @IBInspectable var thickness: CGFloat = 5
    @IBInspectable var innerGap: CGFloat = 0
    @IBInspectable var outerGap: CGFloat = 0
    @IBInspectable var angle: CGFloat = 0
    
    override func drawRect(rect: CGRect) {
        UIColor.clearColor().setFill()
        UIRectFill(rect)
        
        let rads = angle * 2 * pi / 360
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let innerDist = innerGap
        let outerDist = min(bounds.width, bounds.height) / 2 - outerGap

        let innerX = center.x + cos(rads) * innerDist
        let outerX = center.x + cos(rads) * outerDist
        let innerY = center.y - sin(rads) * innerDist
        let outerY = center.y - sin(rads) * outerDist
        let inner = CGPoint(x: innerX, y: innerY)
        let outer = CGPoint(x: outerX, y: outerY)
        
        color.setStroke()
        let path = UIBezierPath()
        path.lineWidth = thickness
        path.moveToPoint(inner)
        path.addLineToPoint(outer)
        path.stroke()
    }

}
