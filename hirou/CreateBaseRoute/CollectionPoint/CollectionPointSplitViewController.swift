//
//  CollectionPointSplitViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 03/06/21.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class CollectionPointSplitViewController: UISplitViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AppUtility.lockOrientation(.all)
    }

    override func viewDidAppear(_ animated: Bool) {
        AppUtility.lockOrientation(.landscape, andRotateTo: .landscapeRight)
    }
}
