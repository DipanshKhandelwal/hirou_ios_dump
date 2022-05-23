//
//  UIView+Extension.swift
//  hirou
//
//  Created by ThuNQ on 10/05/2022.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var viewCornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var viewBorderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var viewBorderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension UICollectionView {
    var centerPoint : CGPoint {
        get {
            return CGPoint(x: self.center.x + self.contentOffset.x, y: self.center.y + self.contentOffset.y);
        }
    }
    
    var centerCellIndexPath: IndexPath? {
        if let centerIndexPath = self.indexPathForItem(at: self.centerPoint) {
            return centerIndexPath
        }
        return nil
    }
}

class ThroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let slideView = subviews.first else {
            return false
        }

        return slideView.hitTest(convert(point, to: slideView), with: event) != nil
    }
}

class ThrouStackView: UIStackView{
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in self.arrangedSubviews {
            let convertedPoint = convert(point, to: subview)
            let labelPoint = subview.point(inside: convertedPoint, with: event)
            if (labelPoint){
                return subview
            }

        }
        return nil
    }

}
