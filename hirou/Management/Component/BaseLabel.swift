//
//  BaseLabel.swift
//  hirou
//
//  Created by ThuNQ on 6/17/22.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import UIKit

class BaseLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 0.0
    @IBInspectable var bottomInset: CGFloat = 0.0
    @IBInspectable var leftInset: CGFloat = 0.0
    @IBInspectable var rightInset: CGFloat = 0.0
    
    @IBInspectable var isRequired: Bool = false  {
        didSet {
            if isRequired {
                setRequiredText(textRequired: textRequired)
            }
        }
    }
    @IBInspectable var textRequired: String? {
        didSet {
            if isRequired {
                setRequiredText(textRequired: textRequired)
            }
        }
    }

    override var text: String? {
        didSet {
            if isRequired {
                setRequiredText()
            }
        }
    }
    

    override func drawText(in rect: CGRect) {
       let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
       get {
          var contentSize = super.intrinsicContentSize
          contentSize.height += topInset + bottomInset
          contentSize.width += leftInset + rightInset
          return contentSize
       }
    }
    
    func setRequiredText(font: UIFont? = nil, textRequired: String? = nil) {
        let font = font ?? self.font
        let required = "*"
        guard let text = text else { return }
        let attributedString = NSMutableAttributedString(string: text)
        let requiredText = NSMutableAttributedString(string: required, attributes: [.foregroundColor: UIColor(0xFF738E), .font: font as Any])
        attributedString.append(requiredText)
        attributedString.addAttributes([.font: font as Any, .foregroundColor: textColor as Any], range: NSRange(location: 0, length: text.count))
        self.attributedText = attributedString
    }
}

