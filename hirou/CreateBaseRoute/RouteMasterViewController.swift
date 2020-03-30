//
//  RouteListTableViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 20/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class RouteTableViewCell : UITableViewCell {
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var garbageTypeLabel: UILabel!
    
}

class RouteMasterViewController: UITableViewController {
    
    var detailViewController: RouteDetailViewController? = nil
    var baseRoutes = [BaseRoute]()
    
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
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? RouteDetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        
        AF.request("http://127.0.0.1:8000/api/base_route/", method: .get).responseJSON { response in
                    
                    //to get status code
                    switch response.result {
                    case .success(let value):
                        self.baseRoutes = []
                        
                        for baseRoute in value as! [Any] {
                            let id = ((baseRoute as AnyObject)["id"] as! Int)
                            let name = ((baseRoute as AnyObject)["name"] as! String)
                            let customer = (((baseRoute as AnyObject)["customer"] as AnyObject)["name"] as! String)
 
                            
                            let baseRouteObj = BaseRoute(id: id, name: name, customer: customer)
                            self.baseRoutes.append(baseRouteObj!)
        //                    self.tableView.reloadData()
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    case .failure(let error):
                        print(error)
        //                completion(nil)
                    }
                    
                }
        
        
        super.viewWillAppear(animated)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.baseRoutes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as! RouteTableViewCell
        
        let route = baseRoutes[indexPath.row]
//        cell.textLabel!.text = route.name
        cell.routeNameLabel?.text = route.name
        cell.customerLabel?.text = route.customer
        cell.garbageTypeLabel?.text = "None for now"
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
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
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRouteDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                //                let object = objects[indexPath.row] as! NSDate
                let route = self.baseRoutes[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! RouteDetailViewController
                //                controller.detailItem = object
                controller.detailItem = route as Any
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }
}
