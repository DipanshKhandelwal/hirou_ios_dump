//
//  CollectionPointMasterViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 24/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class CollectionPointMasterViewController: UITableViewController {
    
    var detailViewController: CollectionPointDetailViewController? = nil
    var collectionPoints = [CollectionPoint]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        //         Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        //        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? CollectionPointDetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        let id = UserDefaults.standard.string(forKey: "selectedRoute")!
        let url = "http://127.0.0.1:8000/api/base_route/"+String(id)+"/"

        AF.request(url, method: .get).responseJSON { response in
            //to get status code
            switch response.result {
            case .success(let value):
                // print(String(data: value as! Data, encoding: .utf8)!)
                // completion(try? SomeRequest(protobuf: value))
                print("response", value)
                // self.vehicles = value as! [Any]
                self.collectionPoints = []
                //                    self.annotations = []
                let cps = (value as AnyObject)["collection_point"]
                
                for collectionPoint in cps as! [Any] {
                    //                    print("collectionPoint", collectionPoint)
                    
                    
                    let id = ((collectionPoint as AnyObject)["id"] as! Int)
                    let name = ((collectionPoint as AnyObject)["name"] as! String)
                    let address = ((collectionPoint as AnyObject)["address"] as! String)
                    let route = ((collectionPoint as AnyObject)["route"] as! Int)
                    
                    let locationCoordinates = ((collectionPoint as AnyObject)["location"] as! String).split{$0 == ","}.map(String.init)
                    let location = Location( latitude: locationCoordinates[0], longitude : locationCoordinates[1] )
                    
                    let sequence = ((collectionPoint as AnyObject)["sequence"] as! Int)
                    // let image = ((collectionPoint as AnyObject)["image"] as! String?)
                    
                    let collectionPointObj = CollectionPoint(id: id, name: name, address: address, route: route, location: location, sequence: sequence, image: "")
                    
                    self.collectionPoints.append(collectionPointObj!)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                //                    self.addPointsTopMap()
                
            case .failure(let error):
                print(error)
            }
        }
        //        }
        
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.collectionPoints.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionPointCell", for: indexPath)
        
        let collectionPoint = collectionPoints[indexPath.row]
        cell.textLabel!.text = collectionPoint.name
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        print("fromIndexPath", fromIndexPath)
        print("to", to)
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCollectionPointDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                //                let object = objects[indexPath.row] as! NSDate
                let collectionPoint = self.collectionPoints[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! CollectionPointDetailViewController
                //                controller.detailItem = object
                controller.detailItem = collectionPoint as Any
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }
}
