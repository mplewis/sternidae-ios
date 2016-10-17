import UIKit

@IBDesignable class NavInfoView: UIView {
    
    @IBInspectable var fontSize: CGFloat = 18
    @IBInspectable var color: UIColor = UIColor.white
    @IBInspectable var key: String = "Key"
    @IBInspectable var value: String = "Value"

    override func draw(_ rect: CGRect) {
        let (top, bottom) = topAndBottomRects()

        let topLabel = UILabel()
        topLabel.text = key
        topLabel.frame = top
        topLabel.font = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightLight)
        topLabel.textColor = color
        topLabel.textAlignment = .center
        addSubview(topLabel)
        
        let bottomLabel = UILabel()
        bottomLabel.text = value
        bottomLabel.frame = bottom
        bottomLabel.font = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightMedium)
        bottomLabel.textColor = color
        bottomLabel.textAlignment = .center
        addSubview(bottomLabel)
    }
    
    func topAndBottomRects() -> (top: CGRect, bottom: CGRect) {
        let top = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 2)
        let bottom = CGRect(x: 0, y: frame.height / 2, width: frame.width, height: frame.height / 2)
        return (top, bottom)
    }

}
