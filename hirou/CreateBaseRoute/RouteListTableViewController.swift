//
//  RouteListTableViewController.swift
//  hirou
//
//  Created by Dipansh Khandelwal on 20/03/20.
//  Copyright © 2020 Dipansh Khandelwal. All rights reserved.
//

import UIKit
import Alamofire

class RouteListTableViewController: UITableViewController {
    
    var baseRoutes = [BaseRoute]()
    @IBOutlet var routeList: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AF.request("http://127.0.0.1:8000/api/base_route/", method: .get).responseJSON { response in
            //to get status code
            switch response.result {
            case .success(let value):
                //                print(String(data: value as! Data, encoding: .utf8)!)
                //                completion(try? SomeRequest(protobuf: value))
//                print("response", value)
                //                self.vehicles = value as! [Any]
                self.baseRoutes = []
                
                for route in value as! [Any] {
//                    print("route", route)
                    
                    let id = ((route as AnyObject)["id"] as! Int)
                    let name = ((route as AnyObject)["name"] as! String)
                    let customer = ((route as AnyObject)["customer"] as AnyObject)
                    let customerName = (customer as AnyObject)["name"] as! String
                    
                    
                    let baseRouteObj = BaseRoute(id: id, name: name, customer: customerName)
                    
                    self.baseRoutes.append(baseRouteObj!)
//                    self.routeList.reloadData()
                    
                }
                
                DispatchQueue.main.async {
                    self.routeList.reloadData()
                }
                //                print("vehicles",self.vehicles)
            //                self.tableView.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        let route = baseRoutes[indexPath.row]
        cell.textLabel!.text = route.name
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
        
        if segue.identifier == "showRouteEdit" {
            if let indexPath = routeList.indexPathForSelectedRow {

                let route = baseRoutes[indexPath.row]
                let controller = (segue.destination as! CreateRouteViewController)
                controller.detailItem = route

//                controller.detailItem = object
//                controller.detailItem = route as Any
//                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
//                controller.navigationItem.leftItemsSupplementBackButton = true
//                detailViewController = controller
            }
        }
     }
}
