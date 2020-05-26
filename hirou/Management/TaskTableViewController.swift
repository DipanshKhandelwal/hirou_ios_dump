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
    
    private var datePicker:  UIDatePicker?

    var date: Date!
    
    func generateRandomDate(daysBack: Int)-> Date?{
        let day = arc4random_uniform(UInt32(daysBack))+1
        let hour = arc4random_uniform(23)
        let minute = arc4random_uniform(59)
        
        let today = Date(timeIntervalSinceNow: 0)
        let gregorian  = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        var offsetComponents = DateComponents()
        offsetComponents.day = -1 * Int(day - 1)
        offsetComponents.hour = -1 * Int(hour)
        offsetComponents.minute = -1 * Int(minute)
        
        let randomDate = gregorian?.date(byAdding: offsetComponents, to: today, options: .init(rawValue: 0) )
        return randomDate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let randomInt = Int.random(in: 0..<30)
        date = generateRandomDate(daysBack: randomInt)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItems = [self.editButtonItem, self.addRouteButton]
        
        let button =  UIButton(type: .system)
        button.setTitle("Button", for: .normal)
        button.addTarget(self, action: #selector(headerClicked), for: .touchUpInside)
        navigationItem.titleView = button
        
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        datePicker?.addTarget(self, action: #selector(TaskTableViewController.dateChanged(datePicker:)), for: .valueChanged)
    }
    
    @objc
    func headerClicked() {
        print("Hello")
    }
    
    @objc
    func dateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        print(dateFormatter.string(from: datePicker.date))
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AF.request("http://127.0.0.1:8000/api/task_route/", method: .get).responseJSON { response in
            //to get status code
            switch response.result {
            case .success(let value):
                self.taskRoutes = []
                for taskRoute in value as! [Any] {
                    let taskRouteResponse = taskRoute as AnyObject
                    let taskRouteObj = TaskRoute.getTaskRouteFromResponse(obj: taskRouteResponse)
                    self.taskRoutes.append(taskRouteObj)
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
                
                print("route sending", route.name)
                
                let controller = (segue.destination as! TaskDetailViewController)
                controller.detailItem = route as Any
            }
        }
    }

}
