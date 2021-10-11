//
//  UrlHelpers.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 11/10/21.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import Foundation
import UIKit

func openUrlInBrowser(url: String) {
    if let url = URL(string: url) {
        UIApplication.shared.open(url)
    }
}
