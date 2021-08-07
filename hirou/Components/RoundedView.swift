import UIKit

@IBDesignable
class RoundedView: UIView {
    override func draw(_ rect: CGRect) {
        layer.masksToBounds = true
        layer.cornerRadius = frame.width/2
        layer.opacity = 0.8
        layer.backgroundColor = UIColor.white.cgColor
    }
}
