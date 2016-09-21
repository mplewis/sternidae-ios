import UIKit

let F_PI = CGFloat(M_PI)

@IBDesignable class CompassView: UIView {
    
    @IBInspectable var outlineColor: UIColor = .white
    @IBInspectable var thickness: CGFloat = 5
    var pointers: [PointerView] = []
    
    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = (min(bounds.width, bounds.height) - thickness) / 2
        
        outlineColor.setStroke()
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * F_PI, clockwise: true)
        path.lineWidth = thickness
        path.stroke()
    }
    
    func newPointer() -> PointerView {
        let pointer = PointerView(frame: bounds)
        pointer.backgroundColor = .clear
        pointer.color = .orange
        pointer.autoresizingMask = [.flexibleHeight, .flexibleWidth]
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
