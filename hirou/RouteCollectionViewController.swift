//
//  MainViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 28/01/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class RouteCollectionViewController: UIViewController {
    @IBOutlet weak var settingsView: UIStackView!
    @IBOutlet weak var managementView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.hidesBackButton = false;
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
