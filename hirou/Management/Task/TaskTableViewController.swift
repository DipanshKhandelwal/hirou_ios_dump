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
    @IBOutlet weak var baseRouteName: UILabel!
}

class TaskTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var taskRoutes = [TaskRoute]()
    var filteredData = [TaskRoute]()
    
    var delegate: PageViewController!
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
        
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.dataSource = self
            self.tableView.delegate = self
        }
    }
    
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
        let parameters: Parameters = [ "date": dateStr, "type": "list" ]
        
        let headers = APIHeaders.getHeaders()
        
        AF.request(Environment.SERVER_URL + "api/task_route/", method: .get, parameters: parameters, headers: headers).validate().response { response in
            //to get status code
            switch response.result {
            case .success(let value):
                let decoder = JSONDecoder()
                self.taskRoutes = try! decoder.decode([TaskRoute].self, from: value!)
                self.filteredData = self.taskRoutes
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
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.filteredData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskTableCell", for: indexPath) as! TaskTableViewCell
        
        let taskRoute = self.filteredData[indexPath.row]
        cell.routeName?.text = taskRoute.name
        cell.routeCustomer?.text = taskRoute.customer?.name ?? "n/a"
        cell.baseRouteName?.text = taskRoute.baseRoute.name

        cell.routeGarbageList?.text = taskRoute.getGarbagesNameList()
        
//        let routeStatus = taskRoute.getCompleteStatus()
//
//        if(routeStatus) {
//            cell.routeStatus?.text = "Complete"
//            cell.routeStatus.textColor = .green
//        } else {
//            cell.routeStatus?.text = "Incomplete"
//            cell.routeStatus.textColor = .red
//        }
        cell.routeStatus?.text = "---"
        cell.routeStatus.textColor = .darkGray

        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            self.filteredData = self.taskRoutes
            self.tableView.reloadData()
        } else {
            self.filteredData = self.taskRoutes.filter({ (taskRoute: TaskRoute) -> Bool in
                let tmp: NSString = taskRoute.name as NSString
                let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
            self.tableView.reloadData()
        }
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
                let route = self.filteredData[indexPath.row]
                let controller = (segue.destination as! TaskDetailViewController)
                controller.detailItem = route as Any
            }
        }
    }

}
