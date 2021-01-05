//
//  MainMenuViewController.swift
//  hirou
//
//  Created by 猪俣貴裕 on 2021/01/06.
//  Copyright © 2021 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        versionLabel.text = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }
    
}
