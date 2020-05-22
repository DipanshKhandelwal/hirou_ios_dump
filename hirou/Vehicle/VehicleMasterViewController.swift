//
//  MasterViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 08/01/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class VehicleMasterViewController: UITableViewController {

    var detailViewController: VehicleDetailViewController? = nil
    var objects = [Any]()
    var vehicles = [Vehicle]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? VehicleDetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        
        AF.request("http://127.0.0.1:8000/api/vehicle/", method: .get).responseJSON { response in
            
            //to get status code
            switch response.result {
            case .success(let value):
                print("response", value)
                self.vehicles = []
                for vehicle in value as! [Any] {
                    let vehicleObject = Vehicle.getVehicleFromResponse(obj: (vehicle as AnyObject))
                    self.vehicles.append(vehicleObject)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
            
        }
        super.viewWillAppear(animated)
    }
    
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                //                let object = objects[indexPath.row] as! NSDate
                let vehicle = vehicles[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! VehicleDetailViewController
                //                controller.detailItem = object
                controller.detailItem = vehicle as Any
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        return objects.count
        return vehicles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //        let object = objects[indexPath.row] as! NSDate
        let vehicle = vehicles[indexPath.row]
        //        cell.textLabel!.text = object.description
        cell.textLabel!.text = vehicle.model
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //        if editingStyle == .delete {
        //            objects.remove(at: indexPath.row)
        //            tableView.deleteRows(at: [indexPath], with: .fade)
        //        } else if editingStyle == .insert {
        //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        //        }
    }
    
    
}

