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
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton
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
//                print(String(data: value as! Data, encoding: .utf8)!)
//                completion(try? SomeRequest(protobuf: value))
                print("response", value)
//                self.vehicles = value as! [Any]
                self.vehicles = []
                
                for vehicle in value as! [Any] {
                    print("vehicle", vehicle)
                    let registrationNumber = ((vehicle as AnyObject)["registration_number"] as! String)
                    let model = ((vehicle as AnyObject)["model"] as! String)
//                    let latitude = ((vehicle as AnyObject)["location"] as! String)
//                    let longitude = ((vehicle as AnyObject)["location"] as! String)
                    let locationCoordinates = ((vehicle as AnyObject)["location"] as! String).split{$0 == ","}.map(String.init)
                    let location = Location( latitude: locationCoordinates[0], longitude : locationCoordinates[1] )
//                    let users = (vehicle as AnyObject)["users"] as! [String]
                    let users: [String] = []
                    let vehicleObject = Vehicle( registrationNumber: registrationNumber, model: model, location: location, users: users)
                    self.vehicles.append(vehicleObject!)
//                    self.tableView.reloadData()
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
//                print("vehicles",self.vehicles)
//                self.tableView.reloadData()
            case .failure(let error):
                print(error)
//                completion(nil)
            }
            
        }
        
        //            { response in
        //            print("response", response)
        //            vehicles = response.result
        //        }
        super.viewWillAppear(animated)
        
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        //        objects.insert(NSDate(), at: 0)
        //        let indexPath = IndexPath(row: 0, section: 0)
        //        tableView.insertRows(at: [indexPath], with: .automatic)
    }
//
//    @objc
//    func insertVehicle(vehicle: Any) {
//        vehicles.insert(vehicle, at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//    }
//
    
    
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

