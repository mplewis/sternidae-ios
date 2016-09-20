import UIKit

let pi = CGFloat(M_PI)

@IBDesignable class CompassView: UIView {
    
    @IBInspectable var outlineColor: UIColor = .whiteColor()
    @IBInspectable var thickness: CGFloat = 5
    var pointers: [PointerView] = []
    
    override func drawRect(rect: CGRect) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (min(bounds.width, bounds.height) - thickness) / 2
        
        outlineColor.setStroke()
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * pi, clockwise: true)
        path.lineWidth = thickness
        path.stroke()
    }
    
    func newPointer() -> PointerView {
        let pointer = PointerView(frame: bounds)
        pointer.backgroundColor = .clearColor()
        pointer.color = .orangeColor()
        pointer.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        pointer.outerGap = thickness
        pointer.thickness = thickness
        addSubview(pointer)
        pointers.append(pointer)
        return pointer
    }
    
    func clearPointers() {
        for pointer in pointers {
            pointer.removeFromSuperview()
        }
        pointers = []
    }

}
