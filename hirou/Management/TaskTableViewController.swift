//
//  TaskTableViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 14/04/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class TaskTableViewCell: UITableViewCell {
    @IBOutlet weak var routeName: UILabel!
    @IBOutlet weak var routeCustomer: UILabel!
    @IBOutlet weak var routeGarbageList: UILabel!
    @IBOutlet weak var routeStatus: UILabel!
}

class TaskTableViewController: UITableViewController {
    var taskRoutes = [TaskRoute]()
    @IBOutlet weak var addRouteButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
                self.navigationItem.rightBarButtonItems = [self.editButtonItem, self.addRouteButton]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AF.request("http://127.0.0.1:8000/api/task_route/", method: .get).responseJSON { response in
            //to get status code
            switch response.result {
            case .success(let value):
                print("value", value)
                self.taskRoutes = []
                for taskRoute in value as! [Any] {
                    let id = ((taskRoute as AnyObject)["id"] as! Int)
                    let name = ((taskRoute as AnyObject)["name"] as! String)
                    
                    let customerResponse = ((taskRoute as AnyObject)["customer"] as AnyObject)
                    let customer = Customer.getCustomerFromAnyObject(obj: customerResponse)
                    
                    let date = ((taskRoute as AnyObject)["date"] as! String)
//                    let garbageArray = (baseRoute as AnyObject)["garbage"]
//                    var garbageList = [Garbage]()
//                    for garbage in garbageArray as! [Any] {
//                        let id = ((garbage as AnyObject)["id"] as! Int)
//                        let name = ((garbage as AnyObject)["name"] as! String)
//                        let description = ((garbage as AnyObject)["description"] as! String)
//                        let garbageObj = Garbage(id: id, name: name, description: description)
//                        garbageList.append(garbageObj!)
//                    }
                    let taskRouteObj = TaskRoute(id: id, name: name, customer: customer, date: date)
                    self.taskRoutes.append(taskRouteObj!)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
                //                completion(nil)
            }
            
        }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.taskRoutes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskTableCell", for: indexPath) as! TaskTableViewCell
        
        let taskRoute = self.taskRoutes[indexPath.row]
        cell.routeName?.text = taskRoute.name
        cell.routeCustomer?.text = taskRoute.customer.name
//        cell.garbageTypeLabel?.text = setGarbageLabelValue(garbageList: route.garbageList)
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showTaskDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let route = self.taskRoutes[indexPath.row]
                
                print("route sending", route.name)
                
                let controller = (segue.destination as! TaskDetailViewController)
                controller.detailItem = route as Any
            }
        }
    }

}