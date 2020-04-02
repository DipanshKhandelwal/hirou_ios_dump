//
//  CollectionPointFormViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 02/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire
import Mapbox

class CollectionPointFormViewController: UIViewController, MGLMapViewDelegate {

    
    @IBOutlet weak var cpNameLabel: UITextField!
    @IBOutlet weak var cpAddressLabel: UITextField!
    @IBOutlet weak var cpCoordinateslabel: UITextField!
    @IBOutlet var cpMapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }
    
    var detailItem: Any? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    func configureView() {
        if let detail = detailItem {
            if let label = self.cpNameLabel {
                label.text = (detail as! CollectionPoint).name
            }
            
            if let label = self.cpAddressLabel {
                label.text = (detail as! CollectionPoint).address
            }
            
            if let label = self.cpCoordinateslabel {
                label.text = String((detail as! CollectionPoint).id)
            }
        }
    }
}
