//
//  DetailViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 08/01/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit

class CityDetailViewController: UIViewController {
    
    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var registrationNumberLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    
    
    func configureView() {
        //         Update the user interface for the detail item.
        if let detail = detailItem {
//            if let label = detailDescriptionLabel {
//                //                label.text = (detail as AnyObject).model
//                label.text = ((detail as AnyObject)["model"] as! String)
//            }
            if let label = modelLabel {
//                label.text = ((detail as AnyObject)["model"] as! String)
                label.text = (detail as! Vehicle).model
            }
            
            if let label = registrationNumberLabel {
                label.text = (detail as! Vehicle).registrationNumber
            }
            
            if let label = coordinatesLabel {
                let location = (detail as! Vehicle).location
//                label.text = location?.latitude ?? "" + " - " + location?.longitude ?? ""
                label.text = location?.latitude ?? ""
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //         Do any additional setup after loading the view.
        configureView()
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
}

