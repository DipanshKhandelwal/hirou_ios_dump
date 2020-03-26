//
//  RouteDetailViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class CollectionPointDetailViewController: UIViewController {
    
    
    
    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var addressTextField: UILabel!
    @IBOutlet weak var idTextField: UILabel!
    
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
            if let label = self.nameTextField {
                label.text = (detail as! CollectionPoint).name
            }
            
            if let label = self.addressTextField {
                label.text = (detail as! CollectionPoint).address
            }
            
            if let label = self.idTextField {
                label.text = String((detail as! CollectionPoint).id)
            }
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destination.
//     // Pass the selected object to the new view controller.
//        if segue.identifier == "showRouteCollectionPoints" {
//            let controller = (segue.destination as! RouteCollectionPointViewController)
//            if let detail = detailItem {
////                print("id", )
//                controller.detailItem = (detail as! BaseRoute).id
//            }
//        }
//
//     }

    
}
