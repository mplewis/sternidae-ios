import UIKit

extension UIView
{
    
    /**
     Starts rotating the view around Z axis.
     
     @param duration Duration of one full 360 degrees rotation. One second is default.
     @param repeatCount How many times the spin should be done. If not provided, the view will spin forever.
     @param clockwise Direction of the rotation. Default is clockwise (true).
     */
    func startZRotation(duration duration: CFTimeInterval = 1, repeatCount: Float = Float.infinity, clockwise: Bool = true)
    {
        if self.layer.animationForKey("transform.rotation.z") != nil {
            return
        }
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        let direction = clockwise ? 1.0 : -1.0
        animation.toValue = NSNumber(double: M_PI * 2 * direction)
        animation.duration = duration
        animation.cumulative = true
        animation.repeatCount = repeatCount
        self.layer.addAnimation(animation, forKey:"transform.rotation.z")
    }
    
    
    /// Stop rotating the view around Z axis.
    func stopZRotation()
    {
        self.layer.removeAnimationForKey("transform.rotation.z")
    }
    
}
