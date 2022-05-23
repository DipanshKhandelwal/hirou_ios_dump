import UIKit

@IBDesignable
class RoundedView: UIView {
    override func draw(_ rect: CGRect) {
        layer.masksToBounds = true
        layer.cornerRadius = frame.height/2
        layer.opacity = 1
        layer.backgroundColor = UIColor.white.cgColor
    }
}
