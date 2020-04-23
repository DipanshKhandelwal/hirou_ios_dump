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
    
//    var detailViewController: RouteDetailViewController? = nil
    var baseRoutes = [BaseRoute]()
    @IBOutlet weak var addRouteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
//         Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//         self.navigationItem.rightBarButtonItem = self.editButtonItem
        
//        navigationItem.leftBarButtonItem = editButtonItem
//
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        navigationItem.rightBarButtonItem = addButton
//        if let split = splitViewController {
//            let controllers = split.viewControllers
//            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? RouteDetailViewController
//        }
        self.navigationItem.rightBarButtonItems = [self.editButtonItem, self.addRouteButton]
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        
        
        AF.request("http://127.0.0.1:8000/api/base_route/", method: .get).responseJSON { response in
                    
                    //to get status code
                    switch response.result {
                    case .success(let value):
                        self.baseRoutes = []
                        for baseRoute in value as! [Any] {
                            let id = ((baseRoute as AnyObject)["id"] as! Int)
                            let name = ((baseRoute as AnyObject)["name"] as! String)
                            let customer = ((baseRoute as AnyObject)["id"] as! Int)
                            let garbageArray = (baseRoute as AnyObject)["garbage"]
                            var garbageList = [Garbage]()
                            for garbage in garbageArray as! [Any] {
                                let id = ((garbage as AnyObject)["id"] as! Int)
                                let name = ((garbage as AnyObject)["name"] as! String)
                                let description = ((garbage as AnyObject)["description"] as! String)
                                let garbageObj = Garbage(id: id, name: name, description: description)
                                garbageList.append(garbageObj!)
                            }
                            let baseRouteObj = BaseRoute(id: id, name: name, customer: customer, garbageList: garbageList)
                            self.baseRoutes.append(baseRouteObj!)
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
        cell.customerLabel?.text = String(route.customer)
        cell.garbageTypeLabel?.text =  route.getGarbagesNameList()
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
    
    @objc
    func insertNewObject(_ sender: Any) {
        
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRouteDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let route = self.baseRoutes[indexPath.row]
                let controller = (segue.destination as! RouteDetailViewController)
                controller.detailItem = route as Any
            }
        }
    }
}
