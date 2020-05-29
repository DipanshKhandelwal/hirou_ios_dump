//
//  DisabledUITextField.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 29/05/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class DisabledUITextField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }    
}
