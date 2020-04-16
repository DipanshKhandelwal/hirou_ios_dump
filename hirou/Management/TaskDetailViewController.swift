//
//  TaskDetailViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 16/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var vehicleLabel: UILabel!
    @IBOutlet weak var garbageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            if let detail = detailItem {
                let taskRoute = detail as! TaskRoute
                print("taskRoute.name", taskRoute.name)
            }
        }
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
