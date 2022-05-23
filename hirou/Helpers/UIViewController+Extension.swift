//
//  UIViewController+Extension.swift
//  hirou
//
//  Created by ThuNQ on 10/05/2022.
//  Copyright © 2022 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    static func top() -> UIViewController? {
        if #available(iOS 13.0, *) {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            return keyWindow?.rootViewController?.top()
        } else {
            return UIApplication.shared.keyWindow?.rootViewController?.top()
        }
    }
    
    func top() -> UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.top()
        }
        else if let tabBarController = self as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return selectedViewController.top()
            }
            return tabBarController.top()
        }
            
        else if let presentedViewController = self.presentedViewController {
            return presentedViewController.top()
        }
        
        else {
            return self
        }
    }
}
