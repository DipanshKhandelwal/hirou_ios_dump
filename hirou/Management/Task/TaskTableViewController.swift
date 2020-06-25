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
    var delegate: PageViewController!
    
    var date: Date? {
         didSet {
             if let foundDate = date {
                 fetchTasks(dateToFetch: foundDate)
             }
         }
     }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchTasks(dateToFetch: self.date ?? Date())
    }
    
    func fetchTasks(dateToFetch: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: dateToFetch)
        let parameters: Parameters = [ "date": dateStr ]
        AF.request(Environment.SERVER_URL + "api/task_route/", method: .get, parameters: parameters).response { response in
            //to get status code
            switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                self.taskRoutes = try! decoder.decode([TaskRoute].self, from: value!)
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
        cell.routeCustomer?.text = taskRoute.customer?.name ?? "n/a"

        cell.routeGarbageList?.text = taskRoute.getGarbagesNameList()
        
        let routeStatus = taskRoute.getCompleteStatus()
        
        if(routeStatus) {
            cell.routeStatus?.text = "Complete"
            cell.routeStatus.textColor = .green
        } else {
            cell.routeStatus?.text = "Incomplete"
            cell.routeStatus.textColor = .red
        }

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
                let controller = (segue.destination as! TaskDetailViewController)
                controller.detailItem = route as Any
            }
        }
    }

}
